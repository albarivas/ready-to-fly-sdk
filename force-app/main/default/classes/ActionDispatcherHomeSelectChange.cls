/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the select "onchange" event defined in the 'apphome' and 'apphome_requests_to_review' views.
*/
public with sharing class ActionDispatcherHomeSelectChange extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(
            Map<String, Object> parameters,
            Slack.RequestContext context
        ) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run() {
            // Gets the slackapp app definition
            Slack.App app = Slack.App.ReadyToFly.get();
            Slack.BotClient botClient = app.getBotClientForTeam(
                context.getTeamId()
            );

            // Gets the userId
            String userId = context.getUserId();

            // Gets the action payload parameters
            Slack.ActionPayload actionPayload = context.getActionPayload();
            if (actionPayload == null) {
                throw new ReadyToFlyException('Wrong action payload');
            }

            String selectedView = (String) actionPayload.getValue();

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
}
