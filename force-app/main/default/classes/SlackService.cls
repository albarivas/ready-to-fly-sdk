public with sharing class SlackService {
    public static Map<String, String> getSlackUserIdsBySalesforceUserId(
        Set<Id> salesforceUserIds
    ) {
        // Get Slack workspace Id
        String teamId = getSlackWorkspaceId();

        // Get user id mappings
        Slack.App app = Slack.App.ReadyToFly.get();

        return (Map<String, String>) app.getConnectedSlackUserIdMap(
            teamId,
            new List<Id>(salesforceUserIds)
        );
    }

    @future(callout=true)
    public static void postToSlack(
        String headerText,
        String bodyText,
        String slackUserId
    ) {
        // Get Slack workspace Id
        String teamId = getSlackWorkspaceId();

        // Get web API bot client
        Slack.App app = Slack.App.ReadyToFly.get();
        Slack.BotClient client = app.getBotClientForTeam(teamId);

        // Post the message
        Slack.ViewReference view = Slack.View.message.get();
        view.setParameter('headerText', headerText);
        view.setParameter('bodyText', bodyText);

        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
            .channel(slackUserId)
            .viewReference(view)
            .build();

        Slack.ChatPostMessageResponse response = client.chatPostMessage(req);

        handleErrors(response);
    }

    // Async version to avoid race condition after approving / rejecting views
    @future(callout=true)
    public static void updateHomePageViewAsync(
        String selectedView,
        String userId,
        String teamId
    ) {
        updateHomePageView(selectedView, userId, teamId);
    }

    public static void updateHomePageView(
        String selectedView,
        String userId,
        String teamId
    ) {
        // Gets the slackapp app definition
        Slack.App app = Slack.App.ReadyToFly.get();
        Slack.BotClient botClient = app.getBotClientForTeam(teamId);

        // Gets the correct apphome view and publishes it
        Slack.ViewReference viewReference;
        if (selectedView == 'myRequests') {
            viewReference = Slack.View.apphome.get();
            viewReference.setParameter(
                'headerText',
                'Recent Travel Requests from ' + UserInfo.getName()
            );
            viewReference.setParameter(
                'instanceUrl',
                URL.getSalesforceBaseUrl().toExternalForm()
            );
        } else if (selectedView == 'requestsToReview') {
            viewReference = Slack.View.apphome_requests_to_review.get();
            viewReference.setParameter(
                'headerText',
                'Travel Requests to Review'
            );
            viewReference.setParameter(
                'instanceUrl',
                URL.getSalesforceBaseUrl().toExternalForm()
            );
        } else {
            throw new ReadyToFlyException('Unknown view type');
        }

        Slack.HomeView homeView = new Slack.HomeView.builder()
            .viewReference(viewReference)
            .build();

        Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder()
            .userId(userId)
            .view(homeView)
            .build();

        Slack.ViewsPublishResponse response = botClient.ViewsPublish(req);
        if (response.getError() != null) {
            System.debug(
                response.getError() +
                ' - ' +
                response.getResponseMetadata()
            );
        }
    }

    private static String getSlackWorkspaceId() {
        // Get Slack workspace Id
        Slack_Workspace_Configuration__mdt workspaceConfiguration = CustomMetadataService.getSlackWorkspaceConfiguration(
            'Apex_SDK_Starter_Kit'
        );
        if (workspaceConfiguration == null) {
            throw new ReadyToFlyException(
                'Missing Slack_Workspace_Configuration__mdt record for Apex_SDK_Starter_Kit'
            );
        }
        return workspaceConfiguration.TeamId__c;
    }

    private static void handleErrors(Slack.ChatPostMessageResponse response) {
        if (response.getError() != null) {
            System.debug(
                response.getError() +
                ' - ' +
                response.getResponseMetadata()
            );
        }
    }
}
