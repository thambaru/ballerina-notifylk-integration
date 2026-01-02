import ballerina/io;

// Configurable variables - values come from Config.toml
configurable string NOTIFY_USER_ID = ?;
configurable string NOTIFY_API_KEY = ?;

public function main() returns error? {
    // Create Notify.lk client using configurable variables
    NotifyClient|error clientResult = createClient(NOTIFY_USER_ID, NOTIFY_API_KEY);
    
    if clientResult is error {
        io:println("Failed to create client: " + clientResult.message());
        return;
    }
    
    NotifyClient notifyClient = clientResult;
    
    // Example 1: Send simple SMS (will fail with test credentials)
    io:println("\n=== Example 1: Simple SMS ===");
    SmsResponse|error smsResult = notifyClient.sendSms(
        to = "9471234567",
        message = "Hello from Ballerina! This is a test message.",
        senderId = "NotifyDEMO"
    );
    
    if smsResult is SmsResponse {
        io:println("✓ SMS Status: " + smsResult.status);
        io:println("✓ SMS Message: " + smsResult.message);
    } else {
        io:println("✗ SMS Error: " + smsResult.message());
    }
    
    // Example 2: Send SMS with contact information
    io:println("\n=== Example 2: SMS with Contact Info ===");
    ContactInfo contact = {
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        address: "123 Main Street, Colombo",
        groupId: 1
    };
    
    SmsResponse|error smsWithContactResult = notifyClient.sendSms(
        to = "9471234567",
        message = "Welcome John! Your account has been created successfully.",
        senderId = "NotifyDEMO",
        contactInfo = contact
    );
    
    if smsWithContactResult is SmsResponse {
        io:println("✓ SMS with Contact Status: " + smsWithContactResult.status);
    } else {
        io:println("✗ SMS with Contact Error: " + smsWithContactResult.message());
    }
    
    // Example 3: Send Unicode SMS
    io:println("\n=== Example 3: Unicode SMS ===");
    SmsResponse|error unicodeSmsResult = notifyClient.sendSms(
        to = "9471234567",
        message = "සුභ උපන්දිනයක්! 🎉 Happy Birthday!",
        senderId = "NotifyDEMO",
        messageType = UNICODE
    );
    
    if unicodeSmsResult is SmsResponse {
        io:println("✓ Unicode SMS Status: " + unicodeSmsResult.status);
    } else {
        io:println("✗ Unicode SMS Error: " + unicodeSmsResult.message());
    }
    
    // Example 4: Check account status
    io:println("\n=== Example 4: Account Status ===");
    AccountStatusResponse|error statusResult = notifyClient.getAccountStatus();
    
    if statusResult is AccountStatusResponse {
        io:println("✓ Account Status: " + statusResult.status);
        if statusResult.data is AccountStatusData {
            AccountStatusData accountData = <AccountStatusData>statusResult.data;
            io:println("✓ Account Active: " + accountData.active.toString());
            io:println("✓ Account Balance: " + accountData.accBalance.toString());
        }
    } else {
        io:println("✗ Status Check Error: " + statusResult.message());
    }
    
    // Example 5: Message length validation
    io:println("\n=== Example 5: Message Length Validation ===");
    string longMessage = "This is a very long message that exceeds the 320 character limit. " +
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod " +
                        "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim " +
                        "veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea " +
                        "commodo consequat. Duis aute irure dolor in reprehenderit in voluptate " +
                        "velit esse cillum dolore eu fugiat nulla pariatur.";
    
    SmsResponse|error longMessageResult = notifyClient.sendSms(
        to = "9471234567",
        message = longMessage,
        senderId = "NotifyDEMO"
    );
    
    if longMessageResult is error {
        io:println("✓ Expected Error: " + longMessageResult.message());
    } else {
        io:println("✗ Unexpected: Long message was accepted");
    }
    
    io:println("\n=== Examples completed! ===");
    io:println("Note: Configure your credentials in Config.toml file for real testing.");
    io:println("Add NOTIFY_USER_ID and NOTIFY_API_KEY to Config.toml with your actual values.");
}