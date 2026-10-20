global without sharing class SoftDrinkOrderStatus {

    global class OrderInfo {
        @InvocableVariable(label='Order Number' description='The soft drink order number that was looked up')
        global Integer orderNumber;

        @InvocableVariable(label='Status' description='Current status of the soft drink order')
        global String status;
    }

    @InvocableMethod(label='Order Status'
                    description='Return Status of the Soft Drink Order , when user ask for it, for example user can say what is the status of My Soft Drink order ABC')
    global static List<OrderInfo> getStatus(List<Integer> orderNumber){

        Soft_Drink_Order__c sd = [SELECT Id, Order_Number__c, Status__c
                                   FROM Soft_Drink_Order__c
                                   WHERE Order_Number__c = :orderNumber[0]
                                   WITH USER_MODE];

        OrderInfo result = new OrderInfo();
        result.orderNumber = orderNumber[0];
        result.status = sd.Status__c;

        return new List<OrderInfo>{ result };
    }
}

/*

[{"actionName":"SoftDrinkOrderStatus","errors":null,"expectedError":false,"invocationId":null,"isSuccess":true,
"outcome":null,"outputValues":{"orderNumber":100.0,"status":"Open"},"sortOrder":0.0,"version":1.0}]


*/