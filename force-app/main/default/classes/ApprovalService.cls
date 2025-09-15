public with sharing class ApprovalService {


    public static void processApprovals(List<Deal__c> deals){


        System.debug('LOG-ONE');


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
                Is_Approved__c = false, // New - To mark the deal initially unapproved 
                Approved_Date__c = null
                ));
            }
        }
        if(!logs.isEmpty())  // important - if nothing in the logs then don't make a trivial insert call to salesforce.
        insert logs;
    }

    private static Id getapprover(String level){

        List<User> user = [Select Id, Name from User where Title =:level Limit 1]; // get user id of the Rerquired Approver.
        // This will be tagged with the record.
        System.debug('LOG-TWO');
        if(user.isEmpty())
        return null;  

        return user[0].Id;
    }


    


    /* AFTER UPDATE TRIGGER CALL -- Below is Newly added login to check oif all approvals are in place, if true then mark the Status of the Deal - Closed Won.
     This will, eventually, triger Commission log    */ 


    /* the idea is to get all deals from approval_log and make a map of DealId, and approval log.
    // Traverse them all, if the Approval_logs of a deal, all of them have is_approved box checked, 
    which would be  done manually, then mark the Status of the deal as Closed_Won */


    public static void evaluateDeals(Set<Id> approvalLogIds){

        // defining the map of dealId and ApprovalLogs. Deal__c is a lookup field in Aproval_Log__c
        Map<Id, List<Approval_Log__c>> dealMap = new Map<Id, List<Approval_Log__c>>();

        // Storing the DealId, Approval_Logs of their respective deals in Map.

        List<Approval_Log__c> approvalLogs = [Select Id, Deal__c, Is_Approved__c from Approval_Log__c where Id in :approvalLogIds];


        for(Approval_Log__c log: approvalLogs){ // taking the Approval Logs of a Deal using SOQL
            if(!dealMap.containsKey(log.Deal__c))
            dealMap.put(log.Deal__c, new List<Approval_log__c>());

            dealMap.get(log.Deal__c).add(log);

        }

        // Now creating a List of Deal__c to update their status to Closed_Won

        List<Deal__c> dealsToUpdate = new List<Deal__c>();

        // Traverse through dealMap to check if all the is_approved box is checked for all the approval logs for a deal.

        for(Id dealId: dealMap.keySet()){
            Boolean all_approved_for_a_deal = true;

            // Here we pick one DealId from the dealMap and pass the dealId to all approval Logs
            // Below gives all approval_logs of a deal then.

            System.debug('APROVAL LOGS ---' + approvalLogs);

            for(Approval_Log__c checkForADeal: dealMap.get(dealId)){
                if(checkForADeal.Is_Approved__c == false)
                all_approved_for_a_deal = false;
                break;  // if at any point, a deal is not approved by manager/VP, then they won't be updated.
            }

            // Creating new Deal Payload for upsert.
            if(all_approved_for_a_deal)
            dealsToUpdate.add(new Deal__c(
                Id = dealId, 
                Status__c = 'Closed_Won'));
            

        }

        if(!dealsToUpdate.isEmpty())
        update dealsToUpdate;

        


    }
}