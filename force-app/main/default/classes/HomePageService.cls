public with sharing class HomePageService {
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
}
