trigger ApprovalLogDealTrigger on Approval_Log__c (after update) {

// creating object of ApprovalLogDealTriggerHandler since it is not static and we'd need an object to access it's methods.

ApprovalLogDealTriggerHandler approvalLogDealTriggerHandler = new ApprovalLogDealTriggerHandler();

if(Trigger.isAfter && Trigger.isUpdate)
approvalLogDealTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);

}