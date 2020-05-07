public class cleanScript {
    public void cleaner(){
        
        List<Case> allCases = [SELECT Id FROM Case ];
        delete allCases;
        
        List<Contact> allContacts = [SELECT Id FROM Contact];
        delete allContacts;
        
        //trigger before delete Account?
        List<Opportunity> oppClose = [SELECT Id FROM Opportunity WHERE StageName='Closed Won'];
        Integer count = oppClose.size(); 
        for(Opportunity op: oppClose){
            op.StageName = 'Prospecting';
        }
        update oppClose;
        
        
        List<Account> allAccounts = [SELECT Id FROM Account];
        delete allAccounts;

    }

}