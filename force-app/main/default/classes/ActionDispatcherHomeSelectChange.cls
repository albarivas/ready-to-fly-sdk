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
            // Gets the action payload parameters
            Slack.ActionPayload actionPayload = context.getActionPayload();
            if (actionPayload == null) {
                throw new ReadyToFlyException('Wrong action payload');
            }

            String selectedView = (String) actionPayload.getValue();

            // Updates home page view
            HomePageService.updateHomePageView(
                selectedView,
                context.getUserId(),
                context.getTeamId()
            );
        }
    }
}
