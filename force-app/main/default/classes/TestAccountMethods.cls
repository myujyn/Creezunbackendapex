@isTest
public with sharing class TestAccountMethods {

    @TestSetup
    static void makeData() {

        // Crée un compte sans commande ni tâche
        DataFactory.createAccount('testAccount1');

        // Crée un compte avec commande + produit
        DataFactory.createOrdersCompleteProcess('testAccount2', 'testProduct2', 1000, 1, 1);

        Account testAccount2 = [
            SELECT Id, OwnerId
            FROM Account
            WHERE Name = 'testAccount2'
            LIMIT 1
        ];

        // Crée une tâche de type "Call"
        Task testTask = new Task(
            WhatId = testAccount2.Id,
            OwnerId = testAccount2.OwnerId,
            Subject = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            IsReminderSet = true,
            ReminderDateTime = Date.today().addDays(5)
        );
        insert testTask;
    }

    @isTest
    static void testGetAccoundIdToOrderMapWhenNoOrder() {
        Set<Id> accountIdSet = getAccountIdsByName('testAccount1');

        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountMethods.getAccountIdToOrderMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(0, mapAccountIdToOrder.size(), 'No order was expected for the account');
    }

    @isTest
    static void testGetAccountIdToOrderMapWhenOrder() {
        Set<Id> accountIdSet = getAccountIdsByName('testAccount2');

        Test.startTest();
        Map<Id, Order> mapAccountIdToOrder = AccountMethods.getAccountIdToOrderMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(1, mapAccountIdToOrder.size(), 'One order was expected for the account');
    }

    @isTest
    static void testGetAccountIdToTaskWhenNoTask() {
        Set<Id> accountIdSet = getAccountIdsByName('testAccount1');

        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountMethods.getAccountIdToTaskMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(0, mapAccountIdToTask.size());
    }

    @isTest
    static void testGetAccountIdToTaskWhenTask() {
        Set<Id> accountIdSet = getAccountIdsByName('testAccount2');

        Test.startTest();
        Map<Id, Task> mapAccountIdToTask = AccountMethods.getAccountIdToTaskMap(accountIdSet);
        Test.stopTest();

        System.assertEquals(1, mapAccountIdToTask.size());
    }

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
