public with sharing class SlackMessage {
    public Id id;
    public String name;
    public String description;
    public String origin;
    public String destination;
    public Date startDate;
    public Date endDate;
    public Decimal cost;
    public String status;
    public String ownerName;
    public String salesforceTargetUserId;
    public String instanceUrl;

    public String getHeader() {
        String header = '';
        if (status == 'New') {
            return 'New Travel Request to review';
        } else if (status == 'Approved') {
            return 'Travel Request approved';
        } else if (status == 'Rejected') {
            return 'Travel Request rejected';
        }
        return header;
    }

    public String getBody() {
        String body = '';
        if (status == 'New') {
            body += 'You have a new Travel Request to review:\n\n';
            body += '*:airplane:' + name + '*:' + description + '\n';
            body += '*From-To:* ' + origin + ' - ' + destination + '\n';
            body += '*Dates:* ' + startDate + '- ' + endDate + '\n';
            body += '*Cost:* ' + cost + '\n';
            body += '*Status:* ' + status + ' :grey_question:\n';
            body += '*Owner:* ' + ownerName;
        } else if (status == 'Approved') {
            String requestURL =
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/' +
                id;
            body += 'Your travel request <' + requestURL + '|' + name + '>';
            body += ' has been approved :tada:. Pack your bags and get started!!!';
        } else if (status == 'Rejected') {
            String requestURL =
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/' +
                id;
            body +=
                'Ops! Your travel request <' +
                requestURL +
                '|' +
                name +
                '>';
            body += ' has been rejected.';
        }
        return body;
    }
}
