public with sharing class ApprovalService {


    public static void processApprovals(List<Deal__c> deals){

        List<Approval_Log__c> logs = new List<Approval_Log__c>();
        for(Deal__c deal: deals){
            // Query approval rules from metadata

            List<Approval_Tier__mdt> rules = [
                Select Region__c, Product__c, Required_Level__c from Approval_Tier__mdt
                where Region__c =:deal.Region__c
                and Product__c = :deal.Product__c
            ];

            for(Approval_Tier__mdt rule: rules){

                logs.add(new Approval_Log__c(
                Name = deal.Name + ' - approval_log - ' + System.now(),
                Deal__c = deal.Id,
                Approver__c = getApprover(rule.Required_Level__c),
                Level__c = rule.Required_Level__c,
                Approved_Date__c = null
                ));
            }
        }

        insert logs;
    }

    private static Id getapprover(String level){

        List<User> user = [Select Id, Name from User where Title =:level Limit 1]; // get user id of the Rerquired Approver.
        // This will be tagged with the record.

        if(user.isEmpty())
        return null;  

        return user[0].Id;
    }

}