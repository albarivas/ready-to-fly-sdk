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
            // Gets the userId
            String event = String.valueOf(parameters.getEvent());
            String userId = event.substringBetween('user=', ',');

            // Updates home page view
            HomePageService.updateHomePageView(
                'myRequests',
                userId,
                context.getTeamId()
            );
        }
    }
}
