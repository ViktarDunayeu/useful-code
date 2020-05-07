public class generateDataScript {
    public void creator(){
        
        Integer rNumAccount = Integer.valueof((Math.random() * 10));
        
        List<Account> newAcc = new List<Account>();
        for(Integer i=0; i<rNumAccount; i++){
            Account a = new Account(Name='Account Name '+ i,
                                    Phone='1337-' + i +'10-' + i,
                                    Type='Other');
            newAcc.add(a);
        }
        
        insert newAcc;
        ////////////////////////////////////////////////////
        List<Contact> newCon = new List<Contact>();
        List<Account> curAcc = [SELECT Id FROM Account];
        for(Account a: curAcc){
            Integer rNumCon = Integer.valueof((Math.random() * 10));
            for(Integer i=0; i<rNumCon; i++){
                Contact c = new Contact(LastName='LName ' + i,
                                        FirstName='My',
                                        Phone='1337-' + i +'10-' + i,
                                        Email='TrueEmail' + i + '@gmail.com',
                                        AccountId=a.Id);
                newCon.add(c);
            }
        }
        insert newCon;
        ///////////////////////////////////////////////////////
        List<Case> newCase = new List<Case>();
        List<Contact> curCon = [SELECT Id FROM Contact];
        for(Contact c: curCon){
            Integer rNumCase = Integer.valueof((Math.random() * 10));
            for(Integer i=0; i<rNumCase; i++){
                Case cas = new Case(Status='New',
                                   	Origin='Email',
                                    Subject='My Sub №' + i,
                                    ContactId=c.Id);
                newCase.add(cas);
            }
        }
        insert newCase;
             
    }

}