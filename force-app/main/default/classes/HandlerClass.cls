public with sharing class HandlerClass {

    // RG-01 : Vérifie que les commandes activées ont au moins un produit
    public static void updateOrderStatus(List<Order> ordersList){
        for (Order order : ordersList) {
            if (order.Status == 'Activated' && order.Number_of_products__c == 0){
                order.addError('Votre commande doit contenir au moins un produit pour être activée');
            }
        }
    }

    // RG-02 : Active les comptes lors de l’insertion de commandes
    public static void activateAccounts(List<Order> ordersList){

        Set<Id> accountsIds = new Set<Id>();
        
        // 🔐 On filtre les AccountId non null
        for (Order order : ordersList){
            if (order.AccountId != null) {
                accountsIds.add(order.AccountId);
            }
        }

        if (accountsIds.isEmpty()) return;

        List<Account> accountsToUpdate = [
            SELECT Id, Active__c
            FROM Account
            WHERE Id IN :accountsIds AND Active__c = false
        ];

        for (Account account : accountsToUpdate){
            account.Active__c = true;
        }

        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }

    // RG-02 : Désactive les comptes si toutes leurs commandes sont supprimées
    public static void deactivateAccounts(List<Order> ordersList){

        Set<Id> accountsIds = new Set<Id>();

        for (Order order : ordersList){
            if (order.AccountId != null) {
                accountsIds.add(order.AccountId);
            }
        }

        if (accountsIds.isEmpty()) return;

        // On vérifie les comptes actifs qui n’ont plus aucune commande
        List<Account> accountsToUpdate = [
            SELECT Id, Active__c
            FROM Account
            WHERE Id IN :accountsIds
              AND Active__c = true
              AND Id NOT IN (SELECT AccountId FROM Order)
        ];

        for (Account account : accountsToUpdate){
            account.Active__c = false;
        }

        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}