@isTest
public with sharing class TestCreateFollowUpTaskBatch {

    @TestSetup
    static void makeData(){

        // Create test accounts
        Account testAccount1 = DataFactory.createAccount('testAccount1');
        insert testAccount1;

        DataFactory.createOrdersCompleteProcess('testAccount2', 'testProduct2', 100, 1, 1);
        
    }

    private static String CRON_EXP = '0 0 0 ? * 2#1'; // At midnight, the 1st Monday of the month, every month

    @isTest
    static void testBatchExecutionCreatesReminderTasks(){
        
        Test.startTest();
        CreateFollowUpTaskBatch testBatch = new CreateFollowUpTaskBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();

        // Verify that tasks are created
        List<Task> tasksOnAccountsList = [
            SELECT Id
            FROM Task
            WHERE WhatId IN (SELECT Id FROM Account WHERE Name LIKE 'testAccount%')
        ];

        System.assertEquals(1, tasksOnAccountsList.size(), 'Unexpected number of tasks created');
    }

    @isTest
    static void testSchedulerCreatesScheduledJob(){

        Test.startTest();
        CreateFollowUpTaskBatch scheduler = new CreateFollowUpTaskBatch();
        String jobId = System.schedule('Test Scheduler', CRON_EXP, scheduler);
        Test.stopTest();

        List<CronTrigger> cts = [
            SELECT Id, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE ID = :jobId];
        System.debug('Next Fire Time' + cts[0].NextFireTime);

        // Verify job is scheduled
        System.assertNotEquals(null, jobId, 'No job was scheduled');
    }
}