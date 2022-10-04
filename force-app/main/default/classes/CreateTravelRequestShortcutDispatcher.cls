/*
    This example apex class extends Slack.ShortcutDispatcher and is responsible for
    responding to both global and message shortcuts registered with the Slack application.
*/
public with sharing class CreateTravelRequestShortcutDispatcher extends Slack.ShortcutDispatcher {
    public override Slack.ActionHandler invoke(
        Slack.ShortcutParameters parameters,
        Slack.RequestContext context
    ) {
        // The slack action handler should immediately be returned.
        return Slack.ActionHandler.modal(
            new Handler(parameters, context),
            'Create Travel Request'
        );
    }

    public class Handler implements Slack.ModalHandler {
        Slack.ShortcutParameters parameters;
        Slack.RequestContext context;

        public Handler(
            Slack.ShortcutParameters parameters,
            Slack.RequestContext context
        ) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            // Returns the modal view for the 'create_travel_request' view definition.
            Slack.ViewReference viewReference = Slack.View.create_travel_request.get();
            Slack.ModalView modalView = new Slack.ModalView.builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }
    }
}
