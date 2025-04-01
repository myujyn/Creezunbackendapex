@isTest
public with sharing class TestCreateFollowUpTaskBatch {

    @TestSetup
    static void makeData() {
        // Crée un compte sans commande (cible du batch)
        DataFactory.createAccount('testAccount1');

        // Crée un compte avec commande (ne doit pas être ciblé)
        DataFactory.createOrdersCompleteProcess('testAccount2', 'testProduct2', 100, 1, 1);
    }

    private static String CRON_EXP = '0 0 0 ? * 2#1'; // 1er lundi du mois

    @isTest
    static void testBatchExecutionCreatesReminderTasks() {
        Test.startTest();
        CreateFollowUpTaskBatch testBatch = new CreateFollowUpTaskBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();

        List<Task> tasksOnAccountsList = [
            SELECT Id
            FROM Task
            WHERE WhatId IN (SELECT Id FROM Account WHERE Name = 'testAccount1')
        ];

        System.assertEquals(1, tasksOnAccountsList.size(), 'A reminder task should be created for inactive account');
    }

    @isTest
    static void testSchedulerCreatesScheduledJob() {
        Test.startTest();
        CreateFollowUpTaskBatch scheduler = new CreateFollowUpTaskBatch();
        String jobId = System.schedule('Test Scheduler', CRON_EXP, scheduler);
        Test.stopTest();

        List<CronTrigger> cts = [
            SELECT Id, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE ID = :jobId
        ];

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
        System.assertEquals(1, cts.size(), 'One cron trigger expected');
    }
}
