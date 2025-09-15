trigger DealTrigger on Deal__c (before insert,after insert,after update) {

    DealTriggerHandler dealTriggerHandler = new DealTriggerHandler();

    if(Trigger.isBefore && Trigger.isInsert) 
    dealTriggerHandler.beforeInsert(Trigger.new);

    if(Trigger.isAfter && Trigger.isInsert)
    dealTriggerHandler.afterInsert(Trigger.new);

    if(Trigger.isAfter && Trigger.isUpdate)
    dealTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);

}



