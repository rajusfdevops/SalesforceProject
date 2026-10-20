global without sharing class SoftDrinkOrderStatus {

    private static final String NOT_FOUND = 'Not found';

    global class OrderInfo {
        @InvocableVariable(label='Order Number' description='The soft drink order number that was looked up')
        global Integer orderNumber;

        @InvocableVariable(label='Status' description='Current status of the soft drink order, with an icon prefix, or "Not found"')
        global String status;
    }

    /**
     * @param orderNumber Single-element list containing the order number to look up.
     * @return Single-element list. Status is "Not found" when the order does not exist or no number is given.
     */
    @InvocableMethod(label='Order Status'
                    description='Return Status of the Soft Drink Order , when user ask for it, for example user can say what is the status of My Soft Drink order ABC')
    global static List<OrderInfo> getStatus(List<Integer> orderNumber) {
        Boolean hasInput = orderNumber != null && !orderNumber.isEmpty() && orderNumber[0] != null;

        OrderInfo result = new OrderInfo();
        result.orderNumber = hasInput ? orderNumber[0] : null;
        result.status = NOT_FOUND;

        if (hasInput) {
            List<Soft_Drink_Order__c> orders = [
                SELECT Status__c
                FROM Soft_Drink_Order__c
                WHERE Order_Number__c = :orderNumber[0]
                WITH USER_MODE
                LIMIT 1
            ];

            if (!orders.isEmpty()) {
                result.status = formatStatus(orders[0].Status__c);
            }
        }

        return new List<OrderInfo>{ result };
    }

    private static String formatStatus(String status) {
        if (status == 'Processed') { return '✅ ' + status; }
        if (status == 'Dispatched') { return '🚚 ' + status; }
        if (status == 'Cancelled') { return '❌ ' + status; }
        if (status == 'Open') { return '🕒 ' + status; }
        return status;
    }
}
