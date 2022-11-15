/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onclick" event defined in the 'apphome_requests_to_review' view "approve" button.
*/
public with sharing class ActionDispatcherApproveTravelRequest extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        // The slack action handler should immediately be returned.
        return Slack.ActionHandler.updateModal(
            new Handler(parameters, context)
        );
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(
            Map<String, Object> parameters,
            Slack.RequestContext context
        ) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            // Process the form data and return the modal view that corresponds to the requested object.
            try {
                // Gets the action payload parameters
                Slack.ActionPayload actionPayload = context.getActionPayload();
                if (actionPayload == null) {
                    throw new ReadyToFlyException('Wrong action payload');
                }

                Id recordId = (Id) actionPayload.getValue();

                Travel_Request__c travelRequest = [
                    SELECT Id, Name, Status__c
                    FROM Travel_Request__c
                    WHERE Id = :recordId
                ];
                travelRequest.Status__c = 'Approved';
                update travelRequest;

                String title = 'Ready to Fly';
                String travelRequestURL =
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/' +
                    travelRequest.Id;
                String travelRequestLink =
                    '<' +
                    travelRequestURL +
                    '|' +
                    travelRequest.Name +
                    '>';
                String body =
                    'Travel Request ' +
                    travelRequestLink +
                    ' was approved successfully :tada: !!!';
                return MessageModal.getMessageModalView(
                    title,
                    new List<String>{ body }
                );
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView getMessageModal(String errorMessage) {
            String title = 'Ready to Fly';
            String body =
                'Ops! travel request approval failed.' +
                '\n' +
                errorMessage;
            return MessageModal.getMessageModalView(
                title,
                new List<String>{ body }
            );
        }
    }
}
