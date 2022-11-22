/**
 * Class used to create sample data
 */
delete [SELECT Id FROM Travel_Request__c];

TestFactory testDataFactory = new TestFactory();
testDataFactory.createMyTravelRequests();
testDataFactory.createTravelRequestsToReview();