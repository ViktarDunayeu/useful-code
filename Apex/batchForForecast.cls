global class batchForForecast implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
        //batchForForecast myBatchObject = new batchForForecast(); 
		//Id batchId = Database.executeBatch(myBatchObject);
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Api_Key__c, Forecast_Service_URL__c, Lower_Limit__c, Lower_Limit_M__c,Normal_Level_Message__c, Upper_Limit__c, Upper_Limit_Message__c FROM Weather_Setting__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Weather_Setting__c> settings){
        
        List<String> optionList = new List<String>();
        Schema.DescribeFieldResult fieldRes = Forecast__c.City__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldRes.getPicklistValues();
        for(Schema.PicklistEntry en: entries){
            optionList.add(en.getLabel());
        }
        
        //Weather_Setting__c WS = [SELECT Api_Key__c, Forecast_Service_URL__c, Lower_Limit__c, Lower_Limit_M__c,
        //                         Normal_Level_Message__c, Upper_Limit__c, Upper_Limit_Message__c
        //                         FROM Weather_Setting__c];
        Weather_Setting__c WS = settings[0];
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        List<List<Forecast__c>> infoForInsert = new List<List<Forecast__c>>();
        
        for(Integer j=0; j<optionList.size(); j++){
            
                String inputNameCity = optionList[j];    
                String endpoint = WS.Forecast_Service_URL__c + '/data/2.5/forecast?q='+inputNameCity+'&appid=' + WS.Api_Key__c;
        
                request.setEndPoint(endpoint);
                request.setMethod('GET');
                HttpResponse response = httpProtocol.send(request);
                
                Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                
                Map<String,Object> v = (Map<String,Object>)data.get('city');
                String NC = String.valueOf(v.get('name'));
                
                List<Object> listOfWeatherDay = (List<Object>)data.get('list');
                Integer size = listOfWeatherDay.size();
                List<Forecast__c> allInfoF = new List<Forecast__c>();
                for(Integer i=0; i<size; i++){
                    //////////////////////////////////////////////
                    Map<String,Object> mapWeatherOfDay = (Map<String,Object>)listOfWeatherDay[i];
                    Map<String,Object> mainW = (Map<String,Object>)mapWeatherOfDay.get('main');
                    
                    Forecast__c forecast = new Forecast__c();
                    
                    Double temperature = Double.valueOf(mainW.get('temp'));
                    String dt_txt = String.valueOf(mapWeatherOfDay.get('dt_txt'));
                    String[] subStr;
                    String delimeter = ' '; 
                    subStr = dt_txt.split(delimeter);
                    
            
                    String[] subStr1;
                    String delimeter1 = '-';
                    subStr1 = subStr[0].split(delimeter1);
                    Integer year = Integer.valueOf(subStr1[0]);
                    Integer month = Integer.valueOf(subStr1[1]);
                    Integer day = Integer.valueOf(subStr1[2]);
                    Date mydate = Date.newInstance(year, month, day);
                    
                    String fullName = NC+'-'+subStr1[2]+'.'+subStr1[1]+'.'+subStr1[0];
                    
                    String[] subStr2;
                    String delimeter2 = ':';
                    subStr2 = subStr[1].split(delimeter2);
                    Integer hour = Integer.valueOf(subStr2[0]);
                    Time mytime = Time.newInstance(hour, 0, 0, 0);
                    
                    forecast.Name = fullName;
                    forecast.Date__c = mydate;
                    forecast.Time__c = mytime;
                    forecast.City__c = NC;
                    forecast.Temperature__c = temperature;
                    
                    allInfoF.add(forecast);
                }
            
            infoForInsert.add(allInfoF);
          
        }
        
        //insert infoForInsert;
        
        List<Forecast__c> f = new List<Forecast__c>();
        for(List<Forecast__c> item: infoForInsert){
            f.addAll(item);
        }
        
        System.debug(f.size());
        insert f;
  
        
        
    }  
    
    global void finish(Database.BatchableContext bc){
        System.debug('OK');
    } 
    
}