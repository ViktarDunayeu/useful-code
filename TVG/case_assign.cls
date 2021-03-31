    /*
    *  @Method          :   setCaseOwner
    *  @Author          :   Alexandr Guzarevich
    *  @Created         :   29.03.2021
    *  @Description     :   Sets necessary Case owner
    *  @Param           :   List<Case> casesList
    */
    public static void setCaseOwner(List<Case> casesList){
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()]; 
        Boolean isFraudAdvisor = !profiles.isEmpty() &&  profiles[0].Name == Constants.PROFILE_FRAUD_ADVISOR;

        if(isFraudAdvisor){
            List<Case> casesToChange = new List<Case>();
            for(Case currentCase: casesList){
                switch on currentCase.SubType__c {
                    when 'General' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_MANUAL_WORK_GENERAL, currentCase));
                    }	
                    when 'Financial Crime (FCT)' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_FINANCIAL_CRIME, currentCase));
                    }
                    when 'Hijack' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_HIJACK, currentCase));
                    }
                    when 'Specialised Liaison' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_SPECIALIST_LIAISON, currentCase));
                    }
                    when 'Payment Fraud' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_PAYMENT_FRAUD, currentCase));
                    }
                    when 'Fraud Trends' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_FRAUD_TRENDS, currentCase));
                    }
                    when 'Serious Query' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_SERIOUS_QUERY, currentCase));
                    }
                    when 'Debt Manager' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_FRAUD_FOLLOW_UP, currentCase));
                    }
                    when 'GLIT' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_GLIT, currentCase));
                    }
                    when 'Service Desk Exceptions' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_SERVICE_DESK, currentCase));
                    }
                    when 'RETBOT' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_GLIT, currentCase));
                    }
                    when 'Standard' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_GENERAL, currentCase));
                    }
                    when 'CIFAS' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_CIFAS, currentCase));
                    }
                    when 'LWI' {
                        casesToChange.add(assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_LWI, currentCase));
                    }
                    when else {
                        casesToChange.add(setCaseOwnerIfSubTypeIsEmpty(currentCase));
                    }
                }
            }
        }
    }

    /*
    *  @Method          :   assignFraudCaseOwner
    *  @Author          :   Alexandr Guzarevich
    *  @Created         :   29.03.2021
    *  @Description     :   Assign Fraud Case to their relevant queues based on value in Subtype field
    *  @Param           :   String queueName
    *  @Param           :   Case currentCase
    */
    public static Case assignFraudCaseOwner(String queueName, Case currentCase){
        Set<String> nameOfQueues = new Set<String>{Constants.CASE_QUEUE_TYPE_NAME_MANUAL_WORK_GENERAL, 
                                                Constants.CASE_QUEUE_TYPE_NAME_FINANCIAL_CRIME, 
                                                Constants.CASE_QUEUE_TYPE_NAME_HIJACK, 
                                                Constants.CASE_QUEUE_TYPE_NAME_SPECIALIST_LIAISON,  
                                                Constants.CASE_QUEUE_TYPE_NAME_PAYMENT_FRAUD, 
                                                Constants.CASE_QUEUE_TYPE_NAME_FRAUD_TRENDS, 
                                                Constants.CASE_QUEUE_TYPE_NAME_SERIOUS_QUERY, 
                                                Constants.CASE_QUEUE_TYPE_NAME_FRAUD_FOLLOW_UP, 
                                                Constants.CASE_QUEUE_TYPE_NAME_GLIT, 
                                                Constants.CASE_QUEUE_TYPE_NAME_SERVICE_DESK, 
                                                Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_GENERAL, 
                                                Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_CIFAS, 
                                                Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_LWI, 
                                                Constants.CASE_QUEUE_TYPE_NAME_CUSTOMER_REQUESTS};
        List<Group> listOfQueues = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :nameOfQueues];

        for(Group groupItem: listOfQueues){
            if(groupItem.DeveloperName == queueName){
                currentCase.OwnerId = groupItem.Id;
            }
        }

        return currentCase;
    }

    /*
    *  @Method          :   setCaseOwnerIfSubTypeIsEmpty
    *  @Author          :   Alexandr Guzarevich
    *  @Created         :   29.03.2021
    *  @Description     :   Assign Fraud Case to their relevant queues, when Subtype field is empty
    *  @Param           :   Case currentCase
    */
    public static Case setCaseOwnerIfSubTypeIsEmpty(Case currentCase){
        if(currentCase.Type == Constants.CASE_TYPE_CUSTOMER_REQUEST){
            currentCase = assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_CUSTOMER_REQUESTS, currentCase);
        } else if (currentCase.Type == Constants.CASE_TYPE_REFFERAL){
            currentCase = assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_GENERAL, currentCase);
        } else if (currentCase.Type == Constants.CASE_TYPE_MANUAL){
            currentCase = assignFraudCaseOwner(Constants.CASE_QUEUE_TYPE_NAME_MANUAL_WORK_GENERAL, currentCase);
        }

        return currentCase;
    }

//Tests
/*
   *  @Method          :   setCaseOwnerTest
   *  @Author          :   Alexandr Guzarevich
   *  @Created         :   29.03.2021
   *  @Description     :   check assign Fraud Case to their relevant queues based on value in Subtype field
   * 					   check assign Fraud Case to their relevant queues, when Subtype field is empty
   *  @Params          :   none
   *  @Return          :   none
   */
  
  /*@IsTest
  private static void setCaseOwnerTest() {
      Profile advisorProfile = [
        SELECT Id, Name
        FROM Profile
        WHERE Name = :Constants.PROFILE_FRAUD_ADVISOR
        LIMIT 1
      ];
      List<user> advisorUser = [
        SELECT Id, Profile.Id
        FROM User
        WHERE ProfileId = :advisorProfile.Id AND isActive = TRUE
      ];
      
      Test.startTest();
      System.runAs(advisorUser[0]){
          Case manualCase = new Case(Origin = 'Phone', Status = Constants.CASE_STATUS_NEW, OwnerId = advisorUser[0].Id, 
                                        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_FRAUD).getRecordTypeId(),
                                     Type = Constants.CASE_TYPE_MANUAL, SubType__c = 'General');
          insert manualCase;
          Case emptyManualCase = new Case(Origin = 'Phone', Status = Constants.CASE_STATUS_NEW, OwnerId = advisorUser[0].Id,
                                          RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_FRAUD).getRecordTypeId(),
                                          Type = Constants.CASE_TYPE_MANUAL);
          insert emptyManualCase;
          Case referralCase = new Case(Origin = 'Phone', Status = Constants.CASE_STATUS_NEW, OwnerId = advisorUser[0].Id, 
                                        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_FRAUD).getRecordTypeId(),
                                     Type = Constants.CASE_TYPE_REFFERAL, SubType__c = Constants.CASE_SUB_TYPE_STANDARD);
          insert referralCase;
          Case emptyReferralCase = new Case(Origin = 'Phone', Status = Constants.CASE_STATUS_NEW, OwnerId = advisorUser[0].Id, 
                                               RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_FRAUD).getRecordTypeId(),
                                            Type = Constants.CASE_TYPE_REFFERAL);
          insert emptyReferralCase;
      }
      Test.stopTest();

      Group manualWorkQueue= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName =: Constants.CASE_QUEUE_TYPE_NAME_MANUAL_WORK_GENERAL];
      List<Case> manualCasesAfterInsert = [SELECT Id, OwnerId FROM Case WHERE OwnerId =: manualWorkQueue.Id];
      System.assertEquals(2, manualCasesAfterInsert.size(), 'The actual number of cases does not match the expected'); 
      
      Group generalReferralQueue= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName =: Constants.CASE_QUEUE_TYPE_NAME_REFERRALS_GENERAL];
      List<Case> referralCasesAfterInsert = [SELECT Id, OwnerId FROM Case WHERE OwnerId =: generalReferralQueue.Id];
      System.assertEquals(2, referralCasesAfterInsert.size(), 'The actual number of cases does not match the expected'); 
  }
    */