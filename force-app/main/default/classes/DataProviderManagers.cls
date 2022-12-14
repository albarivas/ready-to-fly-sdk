/*
    This example apex class is responsible for responding to data provider requests
    for looking up User manager records. See usage defined in the 'create_travel_request' view.
*/
public with sharing class DataProviderManagers {
    public static List<Slack.Option> getManagers() {
        User user = [
            SELECT
                Manager.Name,
                ManagerId,
                Manager.Manager.Name,
                Manager.ManagerId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        List<Slack.Option> managerOptions = new List<Slack.Option>();
        if (user.ManagerId != null) {
            Slack.Option option = new Slack.Option(
                user.Manager.Name,
                user.ManagerId
            );
            managerOptions.add(option);
        }
        if (user.Manager.ManagerId != null) {
            Slack.Option option = new Slack.Option(
                user.Manager.Manager.Name,
                user.Manager.ManagerId
            );
            managerOptions.add(option);
        }

        return managerOptions;
    }
}
