/*
    This example apex class is responsible for responding to data provider requests
    for looking up Travel Request records. See usage defined in the 'app_home' view.
*/
public with sharing class DataProviderTravelRequests {
    public static List<Travel_Request__c> getTravelRequests() {
        List<Travel_Request__c> travelRequests = [
            SELECT
                Id,
                Cost__c,
                Description__c,
                Destination__c,
                End_Date__c,
                Origin__c,
                Start_Date__c,
                Status__c,
                Approver__r.Name,
                Name
            FROM Travel_Request__c
            WHERE OwnerId = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];

        return travelRequests;
    }

    public static List<Travel_Request__c> getTravelRequestsToReview() {
        List<Travel_Request__c> travelRequests = [
            SELECT
                Id,
                Cost__c,
                Description__c,
                Destination__c,
                End_Date__c,
                Origin__c,
                Start_Date__c,
                Status__c,
                Owner.Name,
                Name
            FROM Travel_Request__c
            WHERE Approver__c = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];

        return travelRequests;
    }
}
