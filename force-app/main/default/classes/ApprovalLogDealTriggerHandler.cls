public with sharing class ApprovalLogDealTriggerHandler {

    // parameter 1 - List<Approval_Log__c> newLogs - since a user changes the checkmark, if comes as a Approal_Log__c object after update
    // parameter 2 - Map of existing Approval_Log__c object id and Object along with it.
    public void afterUpdate(List<Approval_Log__c> newLogs, Map<Id, Approval_Log__c> oldMap){

         System.debug('LOG-THREE');
        Set<Id> dealsToBeUpdatedAfterIsApproved = new Set<Id>();  // Rememebr Id here are Deal__c Ids.
 

        for(Approval_Log__c newLog: newLogs){

            Approval_Log__c oldRecord = oldMap.get(newLog.Id);
            if(newLog.is_approved__c == true && oldRecord.is_approved__c == false)
            dealsToBeUpdatedAfterIsApproved.add(newLog.Id);
            System.debug('LOG-dealsToBeUpdatedAfterIsApproved    ' + dealsToBeUpdatedAfterIsApproved);

            
        }

        if(!dealsToBeUpdatedAfterIsApproved.isEmpty())
        ApprovalService.evaluateDeals(dealsToBeUpdatedAfterIsApproved);


    }

}