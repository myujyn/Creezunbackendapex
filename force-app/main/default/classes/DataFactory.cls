@isTest
public with sharing class DataFactory {

    // Crée un compte avec nom
    public static Account createAccount(String accountName) {
        Account acc = new Account(Name = accountName, Active__c = false);
        insert acc;
        return acc;
    }

    // Crée un produit actif
    public static Product2 createProduct(String productName) {
        Product2 product = new Product2(Name = productName, IsActive = true);
        insert product;
        return product;
    }

    // Crée un PricebookEntry
    public static PricebookEntry createPricebookEntry(Id product2Id, Double unitPrice) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    // Crée un contrat lié à un compte
    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert contract;
        return contract;
    }

    // Crée une ou plusieurs commandes liées à un compte
    public static List<Order> createOrders(Id accountId, Integer numberOfOrders) {
        if (accountId == null) {
            Account fallbackAccount = createAccount('Default Test Account');
            accountId = fallbackAccount.Id;
        }

        List<Order> ordersList = new List<Order>();
        for (Integer i = 0; i < numberOfOrders; i++) {
            ordersList.add(new Order(
                AccountId = accountId,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Draft',
                EffectiveDate = Date.today().addDays(30)
            ));
        }
        insert ordersList;
        return ordersList;
    }

    // Crée les OrderItems (produits commandés)
    public static List<OrderItem> createOrderItems(List<Order> ordersList, Id productId, Id pricebookEntryId, Double unitPrice, Integer quantity) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order order : ordersList) {
            orderItems.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = productId,
                PricebookEntryId = pricebookEntryId,
                Quantity = quantity,
                UnitPrice = unitPrice
            ));
        }
        insert orderItems;
        return orderItems;
    }

    // Processus complet : crée compte + produit + contrat + commande(s) + produits
    public static List<Order> createOrdersCompleteProcess(String accountName, String productName, Double unitPrice, Integer numberOfOrders, Integer productQuantity) {

        // Créer le compte
        Account acc = createAccount(accountName);

        // Créer le produit et l’entrée de prix
        Product2 prod = createProduct(productName);
        PricebookEntry pbe = createPricebookEntry(prod.Id, unitPrice);

        // Créer le contrat
        createContract(acc.Id);

        // Créer les commandes
        List<Order> orders = createOrders(acc.Id, numberOfOrders);

        // Créer les OrderItems uniquement si quantité > 0
        if (productQuantity > 0) {
            createOrderItems(orders, prod.Id, pbe.Id, unitPrice, productQuantity);
        }

        return orders;
    }
}
