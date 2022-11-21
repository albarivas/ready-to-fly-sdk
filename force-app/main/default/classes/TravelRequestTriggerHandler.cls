public with sharing class TravelRequestTriggerHandler {
    public static void afterInsert(List<Travel_Request__c> requests) {
        // Preload related records to preserve bulkification
        Map<String, String> slackUserIdsBySalesforceUserId = preloadUserMappings(
            requests
        );
        Map<Id, User> usersById = preloadOwnerNames(requests);

        // Compute messages to post and post them
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            postMessage(request, slackUserIdsBySalesforceUserId, usersById);
        }
    }

    public static void afterUpdate(
        List<Travel_Request__c> requests,
        Map<Id, Travel_Request__c> oldrequestsById
    ) {
        // Preload related records to preserve bulkification
        Map<String, String> slackUserIdsBySalesforceUserId = preloadUserMappings(
            requests
        );
        Map<Id, User> usersById = preloadOwnerNames(requests);

        // Compute messages to post and post them
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            Travel_Request__c oldrequest = oldrequestsById.get(request.Id);
            if (oldrequest.Status__c != request.Status__c) {
                postMessage(request, slackUserIdsBySalesforceUserId, usersById);
            }
        }
    }

    // PRELOADS

    private static Map<String, String> preloadUserMappings(
        List<Travel_Request__c> requests
    ) {
        Set<Id> salesforceUserIds = new Set<Id>();
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            salesforceUserIds.add(request.OwnerId);
            salesforceUserIds.add(request.Approver__c);
        }

        // Retrieve connected slack user Ids
        return SlackService.getSlackUserIdsBySalesforceUserId(
            salesforceUserIds
        );
    }

    private static Map<Id, User> preloadOwnerNames(
        List<Travel_Request__c> requests
    ) {
        Set<Id> ownerIds = new Set<Id>();
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            ownerIds.add(request.OwnerId);
        }
        List<User> users = [SELECT Name FROM User WHERE Id IN :ownerIds];

        return new Map<Id, User>(users);
    }

    // POST MESSAGE LOGIC

    private static void postMessage(
        Travel_Request__c request,
        Map<String, String> slackUserIdsBySalesforceUserId,
        Map<Id, User> usersById
    ) {
        // Find destination Slack user Id
        Id destinationUserId = (request.Status__c == 'New')
            ? request.Approver__c
            : request.OwnerId;
        String targetSlackUserId = slackUserIdsBySalesforceUserId.get(
            (String) destinationUserId
        );

        // Just post message if user authenticated with slack
        if (targetSlackUserId != null) {
            // Build message
            SlackMessage message = new SlackMessage();
            message.id = request.Id;
            message.name = request.Name;
            message.description = request.Description__c;
            message.origin = request.Origin__c;
            message.destination = request.Destination__c;
            message.startDate = request.Start_Date__c;
            message.endDate = request.End_Date__c;
            message.cost = request.Cost__c.intvalue();
            message.status = request.Status__c;
            message.ownerName = usersById.get(request.OwnerId).Name;
            message.instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();

            SlackService.postToSlack(
                message.getHeader(),
                message.getBody(),
                targetSlackUserId
            );
        }
    }
}
