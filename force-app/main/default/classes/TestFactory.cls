public with sharing class TestFactory {
    public User manager;
    public User subordinate;
    public Travel_Request__c tr1;
    public Travel_Request__c tr2;
    public Travel_Request__c tr3;
    public Travel_Request__c tr4;
    public Travel_Request__c tr5;

    private void createManager() {
        Profile standardPlatformUserProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard Platform User'
        ];

        Id myUserId = UserInfo.getUserId();

        String managerName = 'coolmanager' + myUserId + '@trailhead.com';
        List<User> managers = [
            SELECT Id
            FROM User
            WHERE Username = :managerName
        ];

        if (managers.size() == 0) {
            manager = new User();
            manager.FirstName = 'Cool';
            manager.LastName = 'Manager';
            manager.Email = 'coolmanager@trailhead.com';
            manager.Alias = 'cmanager';
            manager.Username = managerName;
            manager.LocaleSidKey = 'en_US';
            manager.TimeZoneSidKey = 'GMT';
            manager.ProfileID = standardPlatformUserProfile.Id;
            manager.LanguageLocaleKey = 'en_US';
            manager.EmailEncodingKey = 'UTF-8';
            insert manager;
        } else {
            manager = managers[0];
        }

        User myUser = [SELECT ManagerId FROM User WHERE Id = :myUserId LIMIT 1];
        myUser.ManagerId = manager.Id;
        update myUser;
    }

    private void createSubordinate() {
        Profile standardPlatformUserProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard Platform User'
        ];

        Id myUserId = UserInfo.getUserId();

        String subordinateName =
            'coolsubordinate' +
            myUserId +
            '@trailhead.com';
        List<User> subordinates = [
            SELECT Id
            FROM User
            WHERE Username = :subordinateName
        ];

        if (subordinates.size() == 0) {
            subordinate = new User();
            subordinate.FirstName = 'Cool';
            subordinate.LastName = 'Subordinate';
            subordinate.Email = 'coolsubordinate@trailhead.com';
            subordinate.Alias = 'csubordinate';
            subordinate.Username = subordinateName;
            subordinate.LocaleSidKey = 'en_US';
            subordinate.TimeZoneSidKey = 'GMT';
            subordinate.ProfileID = standardPlatformUserProfile.Id;
            subordinate.LanguageLocaleKey = 'en_US';
            subordinate.EmailEncodingKey = 'UTF-8';
            subordinate.ManagerId = myUserId;
            insert subordinate;
        } else {
            subordinate = subordinates[0];
        }
    }

    public void createMyTravelRequests() {
        createManager();

        tr1 = new Travel_Request__c();
        tr1.OwnerId = UserInfo.getUserId();
        tr1.Approver__c = manager.Id;
        tr1.Cost__c = 500;
        tr1.Description__c = 'Trip to visit London Developer Group';
        tr1.Origin__c = 'Madrid';
        tr1.Destination__c = 'London';
        tr1.Start_Date__c = Date.newInstance(2022, 6, 1);
        tr1.End_Date__c = Date.newInstance(2022, 6, 3);
        tr1.Status__c = 'Approved';

        tr2 = new Travel_Request__c();
        tr2.OwnerId = UserInfo.getUserId();
        tr2.Approver__c = manager.Id;
        tr2.Cost__c = 3000;
        tr2.Description__c = 'Trip to I love JS conference 2022';
        tr2.Origin__c = 'Madrid';
        tr2.Destination__c = 'Vegas';
        tr2.Start_Date__c = Date.newInstance(2022, 8, 22);
        tr2.End_Date__c = Date.newInstance(2022, 8, 27);
        tr2.Status__c = 'New';

        tr3 = new Travel_Request__c();
        tr3.OwnerId = UserInfo.getUserId();
        tr3.Approver__c = manager.Id;
        tr3.Cost__c = 2000;
        tr3.Description__c = 'Trip for customer X meeting';
        tr3.Origin__c = 'Madrid';
        tr3.Destination__c = 'San Francisco';
        tr3.Start_Date__c = Date.newInstance(2022, 3, 2);
        tr3.End_Date__c = Date.newInstance(2022, 3, 5);
        tr3.Status__c = 'Rejected';

        insert new List<Travel_Request__c>{ tr1, tr2, tr3 };
    }

    public static Travel_Request__c getFreshTravelRequest(Id travelRequestId) {
        return [
            SELECT
                Name,
                OwnerId,
                Approver__c,
                Cost__c,
                Description__c,
                Origin__c,
                Destination__c,
                Start_Date__c,
                End_Date__c,
                Status__c
            FROM Travel_Request__c
            WHERE Id = :travelRequestId
        ];
    }

    public void createTravelRequestsToReview() {
        createSubordinate();

        tr4 = new Travel_Request__c();
        tr4.OwnerId = subordinate.Id;
        tr4.Approver__c = UserInfo.getUserId();
        tr4.Cost__c = 1000;
        tr4.Description__c = 'Trip for customer Y meeting';
        tr4.Origin__c = 'Madrid';
        tr4.Destination__c = 'Paris';
        tr4.Start_Date__c = Date.newInstance(2022, 5, 12);
        tr4.End_Date__c = Date.newInstance(2022, 5, 14);
        tr4.Status__c = 'New';

        tr5 = new Travel_Request__c();
        tr5.OwnerId = subordinate.Id;
        tr5.Approver__c = UserInfo.getUserId();
        tr5.Cost__c = 1000;
        tr5.Description__c = 'Trip for Apex for All Conference 2022';
        tr5.Origin__c = 'Madrid';
        tr5.Destination__c = 'Dublin';
        tr5.Start_Date__c = Date.newInstance(2022, 7, 17);
        tr5.End_Date__c = Date.newInstance(2022, 7, 20);
        tr5.Status__c = 'New';

        insert new List<Travel_Request__c>{ tr4, tr5 };
    }
}
