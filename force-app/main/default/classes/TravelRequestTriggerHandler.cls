public with sharing class TravelRequestTriggerHandler {
    public static void afterInsert(List<Travel_Request__c> requests) {
        // Preload related records to preserve bulkification
        Map<Id, String> slackUserIdsBySalesforceUserId = preloadUserMappings(
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
        Map<Id, String> slackUserIdsBySalesforceUserId = preloadUserMappings(
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

    private static Map<Id, String> preloadUserMappings(
        List<Travel_Request__c> requests
    ) {
        Set<Id> salesforceUserIds = new Set<Id>();
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            salesforceUserIds.add(request.OwnerId);
            salesforceUserIds.add(request.Approver__c);
        }

        // Retrieve connected slack user Ids
        Slack.App app = Slack.App.ReadyToFly.get();

        //TODO Map<Id, String> slackUserIdsBySalesforceUserId = (Map<Id, String>) app.getConnectedSlackUserIdMap(teamId, salesforceUserIds)
        Map<Id, String> slackUserIdsBySalesforceUserId = new Map<Id, String>();

        return slackUserIdsBySalesforceUserId;
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
        Map<Id, String> slackUserIdsBySalesforceUserId,
        Map<Id, User> usersById
    ) {
        // Find destination Slack user Id
        Id destinationUserId = (request.Status__c == 'New')
            ? request.Approver__c
            : request.OwnerId;
        String slackUserId = slackUserIdsBySalesforceUserId.get(
            destinationUserId
        );

        // Just post message if user authenticated with slack
        if (slackUserId != null) {
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
            message.userId = slackUserId;
            message.instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();

            // Post the message
            Slack.App app = Slack.App.ReadyToFly.get();
            //TODO Slack.BotClient client = app.getBotClientForTeam(teamId);
            Slack.BotClient client = app.getBotClientForTeam('xxx');

            Slack.ViewReference view = Slack.View.message.get();
            view.setParameter('headerText', message.getHeader());
            view.setParameter('bodyText', message.getBody());

            /* TODO Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
                .channel(channelId)
                .viewReference(view)
                .build();
            */

            Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
                .channel('yyy')
                .viewReference(view)
                .build();

            Slack.ChatPostMessageResponse response = client.chatPostMessage(
                req
            );
            System.debug('error: ' + response.getError());
        }
    }
}
