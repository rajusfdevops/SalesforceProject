/**
 * Returns recent orders for a soft drink, identified by its exact name, for the
 * HXL "drink orders" MCP widget.
 */
global without sharing class SoftDrinkOrdersByDrink {

    private static final Integer MAX_ORDERS = 10;

    global class OrderRow {
        @InvocableVariable(label='Order Number' description='The soft drink order number')
        global String orderNumber;

        @InvocableVariable(label='Status' description='Current status of the order, with an icon prefix')
        global String status;

        @InvocableVariable(label='Status Color' description='Semantic color token for the status label')
        global String statusColor;

        @InvocableVariable(label='Price' description='Order price, formatted as currency text')
        global String price;

        @InvocableVariable(label='Quantity' description='Quantity ordered, formatted as text')
        global String quantity;
    }

    global class Result {
        @InvocableVariable(label='Drink Name' description='The soft drink name that was searched for')
        global String drinkName;

        @InvocableVariable(label='Order Count' description='Number of orders found')
        global Integer orderCount;

        @InvocableVariable(label='Summary Line' description='Pre-formatted summary, e.g. "3 orders found for Cola"')
        global String summaryLine;

        @InvocableVariable(label='Orders' description='Up to 10 most recent orders for this drink')
        global List<OrderRow> orders;
    }

    /**
     * @param drinkName Single-element list containing the exact Soft_Drink__c name to search for.
     * @return Single-element list containing the matching orders (empty when the drink isn't found).
     */
    @InvocableMethod(label='Get Orders By Drink Name'
                    description='Return recent orders for a soft drink given its exact name, for example "show me all orders for Cola"')
    global static List<Result> getOrders(List<String> drinkName) {
        Result result = new Result();
        result.orders = new List<OrderRow>();

        Boolean hasInput = drinkName != null && !drinkName.isEmpty() && String.isNotBlank(drinkName[0]);
        result.drinkName = hasInput ? drinkName[0] : '';

        if (hasInput) {
            List<Soft_Drink__c> drinks = [
                SELECT Id
                FROM Soft_Drink__c
                WHERE Name = :drinkName[0]
                WITH USER_MODE
                LIMIT 1
            ];

            if (!drinks.isEmpty()) {
                List<Soft_Drink_Order__c> orders = [
                    SELECT Order_Number__c, Status__c, Price__c, Quantity__c
                    FROM Soft_Drink_Order__c
                    WHERE Soft_Drink__c = :drinks[0].Id
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                    LIMIT :MAX_ORDERS
                ];

                for (Soft_Drink_Order__c o : orders) {
                    OrderRow row = new OrderRow();
                    row.orderNumber = formatWholeNumber(o.Order_Number__c);
                    row.status = formatStatus(o.Status__c);
                    row.statusColor = statusColor(o.Status__c);
                    row.price = formatCurrency(o.Price__c);
                    row.quantity = formatWholeNumber(o.Quantity__c);
                    result.orders.add(row);
                }
            }
        }

        result.orderCount = result.orders.size();
        result.summaryLine = result.orderCount == 0
            ? 'No orders yet for ' + result.drinkName
            : result.orderCount + (result.orderCount == 1 ? ' order found for ' : ' orders found for ') + result.drinkName;
        return new List<Result>{ result };
    }

    private static String formatCurrency(Decimal value) {
        return value == null ? '$0.00' : '$' + value.setScale(2);
    }

    private static String formatWholeNumber(Decimal value) {
        return value == null ? '0' : String.valueOf(value.intValue());
    }

    private static String formatStatus(String status) {
        if (status == 'Processed') { return '✅ ' + status; }
        if (status == 'Dispatched') { return '🚚 ' + status; }
        if (status == 'Cancelled') { return '❌ ' + status; }
        if (status == 'Open') { return '🕒 ' + status; }
        return status;
    }

    private static String statusColor(String status) {
        if (status == 'Processed') { return 'success'; }
        if (status == 'Dispatched') { return 'info'; }
        if (status == 'Cancelled') { return 'error'; }
        if (status == 'Open') { return 'warning'; }
        return 'secondary';
    }
}