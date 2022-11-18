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

    public static void postToSlack(SlackMessage message) {
        // Get Slack workspace Id
        String teamId = getSlackWorkspaceId();

        // Get web API bot client
        Slack.App app = Slack.App.ReadyToFly.get();
        Slack.BotClient client = app.getBotClientForTeam(teamId);

        // Post the message
        Slack.ViewReference view = Slack.View.message.get();
        view.setParameter('headerText', message.getHeader());
        view.setParameter('bodyText', message.getBody());

        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
            .channel(message.targetSlackUserId)
            .viewReference(view)
            .build();

        Slack.ChatPostMessageResponse response = client.chatPostMessage(req);

        handleErrors(response);
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
