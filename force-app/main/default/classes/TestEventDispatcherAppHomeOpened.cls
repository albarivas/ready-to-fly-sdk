@isTest
public with sharing class TestEventDispatcherAppHomeOpened {
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.UserSession userSession;

    static {
        // Set up test harness and user session
        slackApp = Slack.App.ReadyToFly.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
    }

    @isTest
    static void testAppHomeOpened() {
        // GIVEN
        TestFactory testDataFactory = new TestFactory();
        testDataFactory.createMyTravelRequests();

        // WHEN
        Test.startTest();
        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);
        Test.stopTest();

        // THEN
        System.assertEquals(8, home.getComponentCount());

        // Check header
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) home.getComponent(
            1,
            Slack.TestHarness.Header.class
        );
        System.assertEquals(
            'Recent Travel Requests from ' + UserInfo.getName(),
            header.getText()
        );

        // Check Approved travel request is correctly displayed
        Travel_Request__c tr1 = TestFactory.getFreshTravelRequest(
            testDataFactory.tr1.Id
        );
        Slack.TestHarness.Section tr1Section = (Slack.TestHarness.Section) home.getComponent(
            3,
            Slack.TestHarness.Section.class
        );
        String expectedText1 =
            '*:airplane:' +
            tr1.Name +
            ':* ' +
            tr1.Description__c +
            '\n ' +
            '*From-To:* ' +
            tr1.Origin__c +
            ' - ' +
            tr1.Destination__c +
            '\n ' +
            '*Dates:* ' +
            formatDate(tr1.Start_Date__c) +
            ' - ' +
            formatDate(tr1.End_Date__c) +
            '\n ' +
            '*Cost:* ' +
            tr1.Cost__c +
            ' USD\n ' +
            '*Status:* ' +
            tr1.Status__c +
            ' :white_check_mark:\n ' +
            '*Approver:* ' +
            testDataFactory.manager.FirstName +
            ' ' +
            testDataFactory.manager.LastName;

        System.assertEquals(expectedText1, tr1Section.getText());

        Slack.TestHarness.Button tr1Button = (Slack.TestHarness.Button) tr1Section.getComponent(
            0,
            Slack.TestHarness.Button.class
        );
        System.assertEquals(
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            tr1.Id,
            tr1Button.getURL()
        );

        // Check New travel request is correctly displayed
        Travel_Request__c tr2 = TestFactory.getFreshTravelRequest(
            testDataFactory.tr2.Id
        );
        Slack.TestHarness.Section tr2Section = (Slack.TestHarness.Section) home.getComponent(
            5,
            Slack.TestHarness.Section.class
        );
        String expectedText2 =
            '*:airplane:' +
            tr2.Name +
            ':* ' +
            tr2.Description__c +
            '\n ' +
            '*From-To:* ' +
            tr2.Origin__c +
            ' - ' +
            tr2.Destination__c +
            '\n ' +
            '*Dates:* ' +
            formatDate(tr2.Start_Date__c) +
            ' - ' +
            formatDate(tr2.End_Date__c) +
            '\n ' +
            '*Cost:* ' +
            tr2.Cost__c +
            ' USD\n ' +
            '*Status:* ' +
            tr2.Status__c +
            ' :grey_question:\n ' +
            '*Approver:* ' +
            testDataFactory.manager.FirstName +
            ' ' +
            testDataFactory.manager.LastName;
        System.assertEquals(expectedText2, tr2Section.getText());

        Slack.TestHarness.Button tr2Button = (Slack.TestHarness.Button) tr2Section.getComponent(
            0,
            Slack.TestHarness.Button.class
        );
        System.assertEquals(
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            tr2.Id,
            tr2Button.getURL()
        );

        // Check Rejected travel request is correctly displayed
        Travel_Request__c tr3 = TestFactory.getFreshTravelRequest(
            testDataFactory.tr3.Id
        );
        Slack.TestHarness.Section tr3Section = (Slack.TestHarness.Section) home.getComponent(
            7,
            Slack.TestHarness.Section.class
        );
        String expectedText3 =
            '*:airplane:' +
            tr3.Name +
            ':* ' +
            tr3.Description__c +
            '\n ' +
            '*From-To:* ' +
            tr3.Origin__c +
            ' - ' +
            tr3.Destination__c +
            '\n ' +
            '*Dates:* ' +
            formatDate(tr3.Start_Date__c) +
            ' - ' +
            formatDate(tr3.End_Date__c) +
            '\n ' +
            '*Cost:* ' +
            tr3.Cost__c +
            ' USD\n ' +
            '*Status:* ' +
            tr3.Status__c +
            ' :x:\n ' +
            '*Approver:* ' +
            testDataFactory.manager.FirstName +
            ' ' +
            testDataFactory.manager.LastName;

        System.assertEquals(expectedText3, tr3Section.getText());

        Slack.TestHarness.Button tr3Button = (Slack.TestHarness.Button) tr3Section.getComponent(
            0,
            Slack.TestHarness.Button.class
        );
        System.assertEquals(
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            tr3.Id,
            tr3Button.getURL()
        );
    }

    private static String formatDate(Date dateToConvert) {
        return ((Datetime) dateToConvert)
            .formatGMT('EEE MMM dd HH:mm:ss z yyyy');
    }
}
