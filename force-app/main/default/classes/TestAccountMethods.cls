@isTest
public with sharing class TestAccountMethods{

    @TestSetup
    static void makeData(){

        // Create test accounts
        Account testAccount1 = DataFactory.createAccount('testAccount1');
        insert testAccount1;

        DataFactory.createOrdersCompleteProcess('testAccount2', 'testProduct2', 1000, 1, 1);

        Account testAccount2 = [
            SELECT Id, OwnerId
            FROM Account
            WHERE Name = 'testAccount2'
        ];

        // Create a test task
        Task testTask = new Task(
            WhatId = testAccount2.Id,
            OwnerId = testAccount2.OwnerId,
            Subject = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            IsReminderSet = true,
            ReminderDateTime = Date.today()+5
        );
        insert testTask;
        
    }

    @isTest
    static void testGetAccoundIdToOrderMapWhenNoOrder(){
        
        // Get test account Ids
        Set<Id> accountIdSet = getAccountIdsByName('testAccount1');

        Test.startTest();
        Map<Id,Order> mapAccountIdToOrder = AccountMethods.getAccountIdToOrderMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(0, mapAccountIdToOrder.size(), 'No order was expected for the account');
    }

    @isTest
    static void testGetAccountIdToOrderMapWhenOrder(){

        // Get test account Ids
        Set<Id> accountIdSet = getAccountIdsByName('testAccount2');

        Test.startTest();
        Map<Id,Order> mapAccountIdToOrder = AccountMethods.getAccountIdToOrderMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(1, mapAccountIdToOrder.size(), 'One order was expected for the accound');
    }

    @isTest
    static void testGetAccountIdToTaskWhenNoTask(){

        // Get test account Ids
        Set<Id> accountIdSet = getAccountIdsByName('testAccount1');

        Test.startTest();
        Map<Id,Task> mapAccountIdToTask = AccountMethods.getAccountIdToTaskMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(0, mapAccountIdToTask.size());
    }

    @isTest
    static void testGetAccountIdToTaskWhenTask(){

        // Get test account Ids
        Set<Id> accountIdSet = getAccountIdsByName('testAccount2');

        Test.startTest();
        Map<Id,Task> mapAccountIdToTask = AccountMethods.getAccountIdToTaskMap(accountIdSet);
        Test.stopTest();
        
        System.assertEquals(1, mapAccountIdToTask.size());
    }

    // Helper methods

    static Set<Id> getAccountIdsByName(String accountName) {
        List<Account> accountsList = [
            SELECT Id
            FROM Account
            WHERE Name = :accountName
        ];

        Set<Id> accountsIds = new Set<Id>();
        for (Account account : accountsList) {
            accountsIds.add(account.Id);
        }
        return accountsIds;
    }
}