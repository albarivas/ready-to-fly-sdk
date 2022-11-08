/* Publish apphome.view using Slack.EventDispatcher */
public class EventDispatcherAppHomeOpened extends Slack.EventDispatcher {
    public override Slack.ActionHandler invoke(
        Slack.EventParameters parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Slack.EventParameters parameters;
        Slack.RequestContext context;

        public Handler(
            Slack.EventParameters parameters,
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
            String event = String.valueOf(parameters.getEvent());
            String userId = event.substringBetween('user=', ',');

            // Gets the apphome view and publish it
            Slack.ViewReference viewReference = Slack.View.apphome.get();
            viewReference.setParameter(
                'headerText',
                'Recent Travel Requests from ' + UserInfo.getName()
            );
            viewReference.setParameter(
                'instanceUrl',
                URL.getSalesforceBaseUrl().toExternalForm()
            );
            Slack.HomeView homeView = new Slack.HomeView.builder()
                .viewReference(viewReference)
                .build();

            Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder()
                .userId(userId)
                .view(homeView)
                .build();

            Slack.ViewsPublishResponse response = botClient.ViewsPublish(req);
            if (response.getError() != null) {
                System.debug(response.getError());
            }
        }
    }
}
