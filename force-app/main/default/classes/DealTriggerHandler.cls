public with sharing class DealTriggerHandler {
   

    public  void beforeInsert(List<SObject> newList){

        List<Deal__c> deals = (List<Deal__c>)newList;
        
        for(Deal__c deal: deals){
            if(String.isBlank(deal.Status__c))
            deal.Status__c = 'draft';
        }
    }


    public void afterInsert(List<SObject> newList){
        List<Deal__c> deals = (List<Deal__c>)newList;

        ApprovalService.processApprovals(deals);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
        //oldMap - previous state of records - before update.

        List<Deal__c> deals = (List<Deal__c>)newList;
        CommissionService.processCommissions(deals, oldMap);
    }


}