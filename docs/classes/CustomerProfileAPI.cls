/**
 * Exposes a complete hotel-customer 360 profile through a custom Apex REST
 * endpoint so an Agentforce agent (via a hosted custom MCP server) can answer
 * questions about a guest.
 *
 * This is the @RestResource equivalent of CustomerMcpService. The ApexDoc on
 * the method becomes the OpenAPI operation description, so it is written for
 * the model that will read it — clear, specific, and action oriented.
 *
 * @see https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/custom-servers.html
 */
@RestResource(urlMapping='/CustomerProfileAPI/*')
global with sharing class CustomerProfileAPI {

    // GET /services/apexrest/CustomerProfileAPI/?customerName=Mukesh
    // Returns a complete 360 profile for the closest matching customer.
    @HttpGet
    global static List<CustomerDetail> doGet() {
        String customerName = RestContext.request.params.get('customerName');
        if (String.isBlank(customerName)) {
            return new List<CustomerDetail>();
        }

        String pattern = '%' + customerName + '%';

        List<Customer__c> customers = [
            SELECT Id, Name, Customer_ID__c, Booking_ID__c, Check_In_Date__c,
                   Mobile_Phone__c, Room_Preferance__c, Status__c,
                   (SELECT Id, Name, Total_Amount__c FROM Food_Bills__r),
                   (SELECT Id, CaseNumber, Subject, Status, Priority, Origin,
                           Description, CreatedDate FROM Cases__r)
            FROM Customer__c
            WHERE Name LIKE :pattern
            WITH USER_MODE
            ORDER BY Name
            LIMIT 1
        ];

        if (customers.isEmpty()) {
            return new List<CustomerDetail>();
        }
        Customer__c customer = customers[0];

        Map<Id, List<FoodItemInfo>> itemsByBillId = new Map<Id, List<FoodItemInfo>>();
        List<Id> billIds = new List<Id>();
        for (Food_Bill__c bill : customer.Food_Bills__r) {
            billIds.add(bill.Id);
        }

        if (!billIds.isEmpty()) {
            for (Food_Item__c item : [
                SELECT Id, Name, Amount__c, Quantity__c, Food_Bill__c,
                       Food_Option__r.Name, Food_Option__r.Price__c,
                       Food_Option__r.Size__c
                FROM Food_Item__c
                WHERE Food_Bill__c IN :billIds
                WITH USER_MODE
                ORDER BY Name
            ]) {
                FoodItemInfo itemInfo = new FoodItemInfo();
                itemInfo.itemId = item.Id;
                itemInfo.itemName = item.Name;
                itemInfo.amount = item.Amount__c;
                itemInfo.quantity = item.Quantity__c;
                if (item.Food_Option__r != null) {
                    itemInfo.foodOptionName = item.Food_Option__r.Name;
                    itemInfo.foodOptionPrice = item.Food_Option__r.Price__c;
                    itemInfo.foodOptionSize = item.Food_Option__r.Size__c;
                }

                if (!itemsByBillId.containsKey(item.Food_Bill__c)) {
                    itemsByBillId.put(item.Food_Bill__c, new List<FoodItemInfo>());
                }
                itemsByBillId.get(item.Food_Bill__c).add(itemInfo);
            }
        }

        CustomerDetail detail = new CustomerDetail();
        detail.customerId = customer.Id;
        detail.name = customer.Name;
        detail.customerNumber = customer.Customer_ID__c;
        detail.bookingId = customer.Booking_ID__c;
        detail.checkInDate = customer.Check_In_Date__c;
        detail.mobilePhone = customer.Mobile_Phone__c;
        detail.roomPreference = customer.Room_Preferance__c;
        detail.status = customer.Status__c;

        detail.foodBills = new List<FoodBillInfo>();
        for (Food_Bill__c bill : customer.Food_Bills__r) {
            FoodBillInfo billInfo = new FoodBillInfo();
            billInfo.billId = bill.Id;
            billInfo.billNumber = bill.Name;
            billInfo.totalAmount = bill.Total_Amount__c;
            billInfo.foodItems = itemsByBillId.containsKey(bill.Id)
                ? itemsByBillId.get(bill.Id)
                : new List<FoodItemInfo>();
            detail.foodBills.add(billInfo);
        }

        detail.roomServiceCases = new List<RoomServiceCaseInfo>();
        for (Case roomCase : customer.Cases__r) {
            RoomServiceCaseInfo caseInfo = new RoomServiceCaseInfo();
            caseInfo.caseId = roomCase.Id;
            caseInfo.caseNumber = roomCase.CaseNumber;
            caseInfo.subject = roomCase.Subject;
            caseInfo.status = roomCase.Status;
            caseInfo.priority = roomCase.Priority;
            caseInfo.origin = roomCase.Origin;
            caseInfo.description = roomCase.Description;
            caseInfo.createdDate = roomCase.CreatedDate;
            detail.roomServiceCases.add(caseInfo);
        }

        return new List<CustomerDetail>{ detail };
    }

    // Concrete return types (not Object) so the OpenAPI generator can describe
    // the full nested response shape.
    global class CustomerDetail {
        global String  customerId;
        global String  name;
        global String  customerNumber;
        global String  bookingId;
        global Date     checkInDate;
        global String  mobilePhone;
        global String  roomPreference;
        global String  status;
        global List<FoodBillInfo> foodBills;
        global List<RoomServiceCaseInfo> roomServiceCases;
    }

    global class FoodBillInfo {
        global String  billId;
        global String  billNumber;
        global Decimal totalAmount;
        global List<FoodItemInfo> foodItems;
    }

    global class FoodItemInfo {
        global String  itemId;
        global String  itemName;
        global Decimal amount;
        global Decimal quantity;
        global String  foodOptionName;
        global Decimal foodOptionPrice;
        global String  foodOptionSize;
    }

    global class RoomServiceCaseInfo {
        global String   caseId;
        global String   caseNumber;
        global String   subject;
        global String   status;
        global String   priority;
        global String   origin;
        global String   description;
        global Datetime createdDate;
    }
}
