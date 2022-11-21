/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onclick" event defined in the 'apphome_requests_to_review' view "approve" button.
*/
public with sharing class ActionDispatcherModifyTravelRequest extends Slack.ActionDispatcher {
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

                // Get onclick parameter
                // Note: we could have passed recordId by parameter too - which is the best practice?
                String travelRequestNewStatus = (String) parameters.get(
                    'travelRequestNewStatus'
                );

                // Approve or reject Travel Request
                Travel_Request__c travelRequest;
                if (
                    (travelRequestNewStatus == 'Approved') ||
                    (travelRequestNewStatus == 'Rejected')
                ) {
                    travelRequest = modifyTravelRequest(
                        recordId,
                        travelRequestNewStatus
                    );
                } else {
                    throw new ReadyToFlyException(
                        'Status not supported: ' + travelRequestNewStatus
                    );
                }

                // Updates home page view
                SlackService.updateHomePageViewAsync(
                    'requestsToReview',
                    context.getUserId(),
                    context.getTeamId()
                );

                // Show modal
                return MessageModal.getMessageModalView(
                    getHeader(travelRequest),
                    new List<String>{ getBody(travelRequest) }
                );
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Travel_Request__c modifyTravelRequest(
            Id recordId,
            String travelRequestNewStatus
        ) {
            Travel_Request__c travelRequest = [
                SELECT Id, Name, Status__c
                FROM Travel_Request__c
                WHERE Id = :recordId
            ];
            travelRequest.Status__c = travelRequestNewStatus;
            update travelRequest;

            return travelRequest;
        }

        private String getHeader(Travel_Request__c travelRequest) {
            String header;
            if (travelRequest.Status__c == 'Approved') {
                header = 'Travel Request approved';
            } else if (travelRequest.Status__c == 'Rejected') {
                header = 'Travel Request rejected';
            } else {
                header = 'Something went wrong';
            }
            return header;
        }

        private String getBody(Travel_Request__c travelRequest) {
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

            String body;
            if (travelRequest.Status__c == 'Approved') {
                body =
                    'Travel Request ' +
                    travelRequestLink +
                    ' was approved successfully :tada: !!!';
            } else if (travelRequest.Status__c == 'Rejected') {
                body =
                    'Ops. Your travel request ' +
                    +travelRequestLink +
                    ' has been rejected.';
            } else {
                body =
                    'Check your travel request ' +
                    +travelRequestLink +
                    ' to know more.';
            }
            return body;
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
