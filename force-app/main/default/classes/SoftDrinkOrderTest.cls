@IsTest
private class SoftDrinkOrderTest {

    @TestSetup
    static void makeData() {
        Soft_Drink__c drink = new Soft_Drink__c(Name = 'Pepsi');
        insert drink;
        insert new Soft_Drink_Order__c(
            Soft_Drink__c = drink.Id,
            Order_Number__c = 100,
            Status__c = 'Open',
            Quantity__c = 20,
            Price__c = 25
        );
    }

    @IsTest
    static void statusReturnsFormattedStatusForExistingOrder() {
        List<SoftDrinkOrderStatus.OrderInfo> results = SoftDrinkOrderStatus.getStatus(new List<Integer>{ 100 });

        Assert.areEqual(1, results.size());
        Assert.areEqual(100, results[0].orderNumber);
        Assert.areEqual('🕒 Open', results[0].status);
    }

    @IsTest
    static void statusReturnsNotFoundForUnknownOrder() {
        List<SoftDrinkOrderStatus.OrderInfo> results = SoftDrinkOrderStatus.getStatus(new List<Integer>{ 999 });

        Assert.areEqual(1, results.size());
        Assert.areEqual(999, results[0].orderNumber);
        Assert.areEqual('Not found', results[0].status);
    }

    @IsTest
    static void statusHandlesMissingInput() {
        List<SoftDrinkOrderStatus.OrderInfo> results = SoftDrinkOrderStatus.getStatus(new List<Integer>());

        Assert.areEqual(1, results.size());
        Assert.isNull(results[0].orderNumber);
        Assert.areEqual('Not found', results[0].status);
    }

    @IsTest
    static void ordersForDrinkReturnsSummaryAndRows() {
        List<SoftDrinkOrdersByDrink.Result> results = SoftDrinkOrdersByDrink.getOrders(new List<String>{ 'Pepsi' });

        Assert.areEqual(1, results[0].orderCount);
        Assert.areEqual('1 order found for Pepsi', results[0].summaryLine);
        Assert.areEqual('100', results[0].orders[0].orderNumber);
        Assert.areEqual('warning', results[0].orders[0].statusColor);
        Assert.areEqual('$25.00', results[0].orders[0].price);
    }

    @IsTest
    static void ordersForUnknownDrinkGivesFriendlyMessage() {
        List<SoftDrinkOrdersByDrink.Result> results = SoftDrinkOrdersByDrink.getOrders(new List<String>{ 'Nope' });

        Assert.areEqual(0, results[0].orderCount);
        Assert.areEqual('No orders yet for Nope', results[0].summaryLine);
        Assert.isTrue(results[0].orders.isEmpty());
    }
}
