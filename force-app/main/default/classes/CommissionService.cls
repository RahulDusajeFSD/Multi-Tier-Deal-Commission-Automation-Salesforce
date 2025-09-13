public with sharing class CommissionService {

    public static void processCommissions(List<Deal__c> deals, Map<Id, SObject> oldMap){

        List<Commission__c> commissions = new List<Commission__c>();


        for(Deal__c deal: deals){
            Deal__c oldDeal = (Deal__c)oldMap.get(deal.Id); // getting Id of the Deal before update

            // only calculate commission if Stage changed to Closed Won

            if(deal.Status__c == 'Closed_Won' && oldDeal.Status__c != 'Closed_Won'){

                Decimal rate = getCommissionRate(deal.Amount__c);

                commissions.add(new Commission__c(
                Name = deal.Name + ' - commission_log - ' + System.now(),
                Deal__c = deal.Id,
                Sales_Rep__c = deal.Assigned_To__c,
                Amount__c = deal.Amount__c,
                Rate__c = rate
                ));
            }

        }

        if(!commissions.isEmpty()){
            insert commissions;
        }




    }


    public static Decimal getCommissionRate(Decimal dealAmount){
        List<Commission_tier__mdt> tiers = [
            Select Min_Amount__c, Max_Amount__c, Rate__c from Commission_tier__mdt 
        ];

        for(Commission_tier__mdt tier: tiers){
            if(dealAmount >= Decimal.valueOf(tier.Min_Amount__c) && dealAmount <=Decimal.valueOf(tier.Max_Amount__c)) {
                return tier.Rate__c;
            }
        }
        return 0;
    }

}