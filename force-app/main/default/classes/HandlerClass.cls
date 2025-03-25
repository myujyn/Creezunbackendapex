public with sharing class HandlerClass {

    // Method to validate orders status and number of products
    public static void updateOrderStatus(List<Order> ordersList){

        for (Order order : ordersList) {

            /* Number_of_products__c (Roll-Up Summary COUNT) : Counts the number of Order Product records related to the Order. 
            FYI it is natively not possible to create an Order Product with 0 quantity 
            If the condition is false, the update occurs. If not, an error message displays*/

            if (order.Status == 'Activated' && order.Number_of_products__c == 0){
                // Add error message to prevent activation of orders without products
                order.addError('Your Order must have at least one product to be activated');
            }
        }
    }

    // Method to activate accounts associated with orders
    public static void activateAccounts(List<Order> ordersList){
        
        // First, we retrieve unique account IDs from orders in the trigger list
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : ordersList){
            accountsIds.add(order.AccountId);
        }

        // Then, we query inactive accounts associated with orders in the trigger list
        List<Account> accountsToUpdate = [
            SELECT Id, Active__c
            FROM Account
            WHERE Id IN:accountsIds AND Active__c = false
        ];

        // Finally, we activate the accounts found that are inactive
        for (Account account : accountsToUpdate){
            account.Active__c = true;
        }

        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
        
    }

    // Method to deactivate accounts not associated with orders
    public static void deactivateAccounts(List<Order> ordersList){

        // First, we retrieve unique account IDs from orders in the trigger list
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : ordersList){
            accountsIds.add(order.AccountId);
        }

        // Then, we query active accounts not associated with any orders in the trigger list
        List<Account> accountsToUpdate = [
            SELECT Id, Active__c
            FROM Account
            WHERE Id IN:accountsIds
            AND Active__c = true
            AND Id NOT IN (SELECT AccountId FROM Order)
        ];

        // Finally, we deactive the accounts found that are not associated with any order
        for (Account account : accountsToUpdate){
            account.Active__c = false;
        }

        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }

}