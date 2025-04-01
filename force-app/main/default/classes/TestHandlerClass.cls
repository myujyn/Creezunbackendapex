@isTest
public with sharing class TestHandlerClass {

    @TestSetup
    static void makeData() {
        DataFactory.createOrdersCompleteProcess('testAccount1', 'testProduct1', 100, 1, 1); // Avec produits
        DataFactory.createOrdersCompleteProcess('testAccount2', 'testProduct2', 100, 1, 0); // Sans produits
    }

    @isTest
    static void testUpdateStatusOrderWithProduct() {
        List<Order> ordersList = getOrdersByAccountName('testAccount1');
        for (Order order : ordersList) {
            order.Status = 'Activated';
        }

        Test.startTest();
        update ordersList;
        Test.stopTest();

        List<Order> updatedOrdersList = getOrdersByStatus('Activated');
        System.assertEquals(1, updatedOrdersList.size(), 'One order should have been updated');
    }

    @isTest
    static void testUpdateStatusOrderWithNoProduct() {
        List<Order> ordersList = getOrdersByAccountName('testAccount2');
        for (Order order : ordersList) {
            order.Status = 'Activated';
        }

        Boolean errorThrown = false;
        Test.startTest();
        try {
            update ordersList;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorThrown, 'An error should be thrown when activating order without product');
    }

    @isTest
    static void testAccountIsInactiveOnCreation() {
        Account account = DataFactory.createAccount('testAccount3');
        Account fresh = [SELECT Active__c FROM Account WHERE Id = :account.Id];
        System.assertEquals(false, fresh.Active__c, 'Account should be inactive on creation');
    }

    @isTest
    static void testAccountIsActivatedOnOrderCreation() {
        Account account = DataFactory.createAccount('testAccount4');
        Contract contract = DataFactory.createContract(account.Id);
        List<Order> ordersList = DataFactory.createOrders(account.Id, 1);

        Account activatedAccount = [
            SELECT Active__c FROM Account WHERE Id = :account.Id
        ];

        System.assertEquals(true, activatedAccount.Active__c, 'Account should be active after order creation');
    }

    @isTest
    static void testAccountIsDeactivatedOnOrderDeletion() {
        Account account = DataFactory.createAccount('testAccount5');
        DataFactory.createContract(account.Id);
        List<Order> ordersList = DataFactory.createOrders(account.Id, 1);
        delete ordersList;

        Account deactivatedAccount = [
            SELECT Active__c FROM Account WHERE Id = :account.Id
        ];

        System.assertEquals(false, deactivatedAccount.Active__c, 'Account should be inactive after order deletion');
    }

    // Helpers
    static List<Order> getOrdersByAccountName(String accountName) {
        return [
            SELECT Id, OrderNumber, Account.Name
            FROM Order
            WHERE Account.Name = :accountName
        ];
    }

    static List<Order> getOrdersByStatus(String status) {
        return [
            SELECT Id, OrderNumber
            FROM Order
            WHERE Status = :status
        ];
    }
}
