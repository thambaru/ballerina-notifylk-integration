import ballerina/io;
import thambaru/notifylk_integration as notify;

// Configurable variables - values come from Config.toml
configurable string NOTIFY_USER_ID = ?;
configurable string NOTIFY_API_KEY = ?;

public function main() returns error? {
    // Create Notify.lk client using configurable variables
    notify:NotifyClient client = check notify:createClient(NOTIFY_USER_ID, NOTIFY_API_KEY);
    
    // Example 1: Send simple SMS
    io:println("=== Sending Simple SMS ===");
    notify:SmsResponse|error smsResult = client.sendSms(
        to = "9471234567",
        message = "Hello from Ballerina! This is a test message.",
        senderId = "NotifyDEMO"
    );
    
    if smsResult is notify:SmsResponse {
        io:println("SMS Status: " + smsResult.status);
        io:println("SMS Message: " + smsResult.message);
    } else {
        io:println("SMS Error: " + smsResult.message());
    }
    
    // Example 2: Send SMS with contact information
    io:println("\n=== Sending SMS with Contact Info ===");
    notify:ContactInfo contact = {
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        address: "123 Main Street, Colombo",
        groupId: 1
    };
    
    notify:SmsResponse|error smsWithContactResult = client.sendSms(
        to = "9471234567",
        message = "Welcome John! Your account has been created successfully.",
        senderId = "NotifyDEMO",
        contactInfo = contact
    );
    
    if smsWithContactResult is notify:SmsResponse {
        io:println("SMS with Contact Status: " + smsWithContactResult.status);
    } else {
        io:println("SMS with Contact Error: " + smsWithContactResult.message());
    }
    
    // Example 3: Send Unicode SMS
    io:println("\n=== Sending Unicode SMS ===");
    notify:SmsResponse|error unicodeSmsResult = client.sendSms(
        to = "9471234567",
        message = "සුභ උපන්දිනයක්! 🎉 Happy Birthday!",
        senderId = "NotifyDEMO",
        messageType = notify:UNICODE
    );
    
    if unicodeSmsResult is notify:SmsResponse {
        io:println("Unicode SMS Status: " + unicodeSmsResult.status);
    } else {
        io:println("Unicode SMS Error: " + unicodeSmsResult.message());
    }
    
    // Example 4: Check account status
    io:println("\n=== Checking Account Status ===");
    notify:AccountStatusResponse|error statusResult = client.getAccountStatus();
    
    if statusResult is notify:AccountStatusResponse {
        io:println("Account Status: " + statusResult.status);
        if statusResult.data is notify:AccountStatusData {
            io:println("Account Active: " + statusResult.data.active.toString());
            io:println("Account Balance: " + statusResult.data.accBalance.toString());
        }
    } else {
        io:println("Status Check Error: " + statusResult.message());
    }
    
    // Example 5: Error handling for long messages
    io:println("\n=== Testing Message Length Validation ===");
    string longMessage = "This is a very long message that exceeds the 320 character limit. " +
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod " +
                        "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim " +
                        "veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea " +
                        "commodo consequat. Duis aute irure dolor in reprehenderit in voluptate " +
                        "velit esse cillum dolore eu fugiat nulla pariatur.";
    
    notify:SmsResponse|error longMessageResult = client.sendSms(
        to = "9471234567",
        message = longMessage,
        senderId = "NotifyDEMO"
    );
    
    if longMessageResult is error {
        io:println("Expected Error: " + longMessageResult.message());
    } else {
        io:println("Unexpected: Long message was accepted");
    }
}