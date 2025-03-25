global with sharing class CreateFollowUpTaskBatch implements Database.Batchable<SObject>, Schedulable {

    // Start method returns the query locator for the batch job
    global Database.QueryLocator start(Database.BatchableContext bc){

        // Query all inactive accounts without reminders
        return Database.getQueryLocator([
            SELECT Id, OwnerId
            FROM Account
            WHERE Active__c = false
        ]);
    }

    // Execute methode creates tasks for each account withtout associated order or task
    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        // List to hold new task recors to be inserted
        List<Task> tasksList = new List<Task>();

        // Set to hold accounts Ids for efficient querying
        Set<Id> accountIdSet = (new Map<Id,SObject>(scope)).keySet();

        // Query orders and tasks associated with the accounts
        Map<Id,Order> mapAccountIdToOrder = AccountMethods.getAccountIdToOrderMap(accountIdSet);
        Map<Id,Task> mapAccountIdToTask = AccountMethods.getAccountIdToTaskMap(accountIdSet);

        // Loop through each account in the batch
        for (Account account : scope){

            // Check if the account has no associated order or task
            if (mapAccountIdToOrder.get(account.id) == null && mapAccountIdToTask.get(account.id) == null){

                // Create a new task for the account
                Task task = new Task(
                    WhatId = account.Id,
                    OwnerId = account.OwnerId,
                    Subject = 'Call',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    IsReminderSet = true,
                    ReminderDateTime = Date.today()+5
                );
                tasksList.add(task); // Add task to the list
            }
        }
        insert tasksList; // Insert all new tasks
    }

    // Finish method is called after the batch job is completed
    global void finish(Database.BatchableContext bc){
        // Additional cleanup or post-processing can be performed here
    }

    // Execute method to schedule the batch job
    global void execute(SchedulableContext sc){
        CreateFollowUpTaskBatch scheduledBatch = new CreateFollowUpTaskBatch();
        Database.executeBatch(scheduledBatch);
    }

}