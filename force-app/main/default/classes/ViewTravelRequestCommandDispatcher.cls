public with sharing class ViewTravelRequestCommandDispatcher extends Slack.SlashCommandDispatcher {
    public override Slack.ActionHandler invoke(
        Slack.SlashCommandParameters parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.modal(
            new Handler(parameters, context),
            'my custom modal title'
        );
    }

    public class Handler implements Slack.ModalHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public Handler(
            Slack.SlashCommandParameters parameters,
            Slack.RequestContext context
        ) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            // Retrieve the Travel Request name from the slash command String
            String commandText = this.parameters.getText();
            String[] commandSegments = commandText.split(' ');
            String errMessage = 'The view record command requires 1 argument: travelRequestName.';
            if (commandSegments.size() < 1) {
                return MessageModal.getMessageModalView(
                    'Invalid Parameters',
                    new List<String>{ errMessage }
                );
            }

            String travelRequestName = commandSegments[0];

            // Query Travel_Request__c to get Status
            List<Travel_Request__c> travelRequests = [
                SELECT Status__c
                FROM Travel_Request__c
                WHERE Name = :travelRequestName
                WITH SECURITY_ENFORCED
            ];
            if (travelRequests.isEmpty()) {
                return MessageModal.getMessageModalView(
                    'Error',
                    new List<String>{ 'Travel Request not found' }
                );
            }

            // Build the view and return the modal
            String title = 'Travel Request Status';
            String message =
                'Your travel request ' +
                travelRequestName +
                ' status is: ' +
                travelRequests[0].Status__c;
            return MessageModal.getMessageModalView(
                title,
                new List<String>{ message }
            );
        }
    }
}
