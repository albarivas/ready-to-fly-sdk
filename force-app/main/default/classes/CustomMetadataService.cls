public with sharing class CustomMetadataService {
    public static Slack_Workspace_Configuration__mdt getSlackWorkspaceConfiguration(
        String name
    ) {
        return [
            SELECT MasterLabel, QualifiedApiName, TeamId__c
            FROM Slack_Workspace_Configuration__mdt
            WHERE QualifiedApiName = :name
            LIMIT 1
        ];
    }
}
