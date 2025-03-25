public with sharing class AccountMethods {

    /**
     * Retrieves a map of AccountId to Order objects based on the provided set of AccountIds
     * 
     * @param accountIdSet A set of AccountIds for which we want to retrieve Orders
     * @return A map of AccountId to Order objects
     */

    public static Map<Id,Order> getAccountIdToOrderMap(Set<Id> accountIdSet){

        Map<Id,Order> accountIdToOrderMap = new Map<Id,Order>();

        // Query Orders related to the provided AccountIds
        List<Order> ordersList = [
            SELECT Id, AccountId
            FROM Order
            WHERE AccountId IN: accountIdSet
        ];

        // Populate the map with AccountId as key and corresponding Order as value
        for (Order order : ordersList) {
            accountIdToOrderMap.put(order.AccountId, order);
        }   

        return accountIdToOrderMap;
    }

    /**
     * Retrieves a map of AccountId to Task objects based on the provided set of AccountIds
     * 
     * @param accountIdSet A set of AccountIds for which we want to retrieve Tasks
     * @return A map of AccountId to Task objects
     */

    public static Map<Id,Task> getAccountIdToTaskMap(Set<Id> accountIdSet){

        Map<Id,Task> accountIdToTaskMap = new Map<Id,Task>();

        // Query Tasks related to the provided AccountIds
        List<Task> tasksList = [
            SELECT Id, WhatId
            FROM Task
            WHERE WhatId IN: accountIdSet
        ];

        // Populate the map with AccountId as key and corresponding Task as value
        for (Task task : tasksList){
            accountIdToTaskMap.put(task.WhatId, task);
        }

        return accountIdToTaskMap;
    }
}