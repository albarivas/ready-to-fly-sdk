/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onsubmit" event defined in the 'create_account', 'create_contact',
    and 'create_opportunty' views.
*/
public with sharing class ActionDispatcherSubmitTravelRequest extends Slack.ActionDispatcher {
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
                Map<String, Object> formData = this.context.getFormData();
                if (formData.isEmpty()) {
                    throw new ReadyToFlyException('Missing form data');
                }
                Travel_Request__c travelRequest = new Travel_Request__c();
                travelRequest.Origin__c = (String) formData.get('Origin__c');
                travelRequest.Destination__c = (String) formData.get(
                    'Destination__c'
                );
                travelRequest.Start_Date__c = Date.valueOf(
                    (String) formData.get('Start_Date__c')
                );
                travelRequest.End_Date__c = Date.valueOf(
                    (String) formData.get('End_Date__c')
                );
                travelRequest.Cost__c = Double.valueOf(formData.get('Cost__c'));
                travelRequest.Approver__c = (String) formData.get(
                    'Approver__c'
                );
                if (formData.containsKey('Description__c')) {
                    travelRequest.Description__c = (String) formData.get(
                        'Description__c'
                    );
                }
                insert travelRequest;

                travelRequest = [
                    SELECT Name
                    FROM Travel_Request__c
                    WHERE Id = :travelRequest.Id
                    WITH SECURITY_ENFORCED
                ];

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
                    ' was created successfully :tada: !!!';
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
                'Ops! travel request creation failed.' +
                '\n' +
                errorMessage;
            return MessageModal.getMessageModalView(
                title,
                new List<String>{ body }
            );
        }
    }
}
