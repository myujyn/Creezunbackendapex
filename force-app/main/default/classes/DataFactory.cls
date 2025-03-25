@isTest
public with sharing class DataFactory {

    public static Account createAccount(String accountName) {
        return new Account(Name = accountName);
    }

    public static Product2 createProduct(String productName) {
        return new Product2(Name = productName, IsActive = true);
    }

    public static PricebookEntry createPricebookEntry(String product2Id, Double unitPrice) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        return pricebookEntry;
    }

    public static Contract createContract(String accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        return contract;
    }

    public static List<Order> createOrders(String accountId, Integer numberOfOrders){
        List<Order> ordersList = new List<Order>();

        for (Integer i=0; i < numberOfOrders; i++){
            Order order = new Order(
                AccountId = accountId,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Draft',
                EffectiveDate = Date.today()+30
            );
            ordersList.add(order);
        }
        return ordersList;
    }

    public static List<OrderItem> createOrderItems(List<Order> ordersList, Map<String,String> data, Double unitPrice, Integer productQuantity){
        List<OrderItem> orderItems = new List<OrderItem>();

        for (Order order : ordersList){
            OrderItem orderItem = new orderItem(
                OrderId = order.Id,
                Product2Id = data.get('Product2Id'),
                PricebookEntryId = data.get('PricebookEntryId'),
                Quantity = productQuantity,
                UnitPrice = unitPrice
            );
            orderItems.add(orderItem);
        }
        return orderItems;
    }

    public static List<Order> createOrdersCompleteProcess(String accountName, String productName, Double unitPrice, Integer numberOfOrders, Integer productQuantity){

        Account account = DataFactory.createAccount(accountName);
        insert account;

        Product2 product = DataFactory.createProduct(productName);
        insert product;

        PricebookEntry pricebookEntry = DataFactory.createPricebookEntry(product.Id, unitPrice);
        insert pricebookEntry;

        Contract contract = DataFactory.createContract(account.Id);
        insert contract;

        List<Order> orders = DataFactory.createOrders(account.Id, numberOfOrders);
        insert orders;

        Map<String,String> mapProductWithPricebookEntry = new Map<String,String>{
            'Product2Id' => product.Id,
            'PricebookEntryId' => pricebookEntry.Id
        };



        if (productQuantity > 0){ // Order Line Item is created only if productQuantity is greater than 0, if not Order remains empty
            List<OrderItem> orderItems = DataFactory.createOrderItems(orders, mapProductWithPricebookEntry, unitPrice, productQuantity);
            insert orderItems;
        }
        return orders;
    }
}