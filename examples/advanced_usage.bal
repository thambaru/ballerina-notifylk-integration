import ballerina/io;
import thambaru/notifylk_integration as notify;

// Configurable variables - values come from Config.toml
configurable string NOTIFY_USER_ID = ?;
configurable string NOTIFY_API_KEY = ?;

// Bulk SMS recipient information
type Recipient record {|
    string phoneNumber;
    string firstName;
    string lastName;
    string? email;
|};

public function main() returns error? {
    // Create Notify.lk client using configurable variables
    notify:NotifyClient notifyClient = check notify:createClient(NOTIFY_USER_ID, NOTIFY_API_KEY);
    
    // Example 1: Bulk SMS sending
    io:println("=== Bulk SMS Example ===");
    
    Recipient[] recipients = [
        {phoneNumber: "9471234567", firstName: "John", lastName: "Doe", email: "john@example.com"},
        {phoneNumber: "9471234568", firstName: "Jane", lastName: "Smith", email: "jane@example.com"},
        {phoneNumber: "9471234569", firstName: "Bob", lastName: "Johnson", email: ()}
    ];
    
    foreach Recipient recipient in recipients {
        string personalizedMessage = string `Hello ${recipient.firstName}! Welcome to our service.`;
        
        notify:ContactInfo contact = {
            firstName: recipient.firstName,
            lastName: recipient.lastName,
            email: recipient.email
        };
        
        notify:SmsResponse|error result = notifyClient.sendSms(
            to = recipient.phoneNumber,
            message = personalizedMessage,
            senderId = "NotifyDEMO",
            contactInfo = contact
        );
        
        if result is notify:SmsResponse {
            io:println(string `✓ SMS sent to ${recipient.firstName}: ${result.status}`);
        } else {
            io:println(string `✗ Failed to send SMS to ${recipient.firstName}: ${result.message()}`);
        }
        
        // Add small delay between requests to avoid rate limiting
        // In real applications, you might want to implement proper rate limiting
    }
    
    // Example 2: SMS with retry logic
    io:println("\n=== SMS with Retry Logic ===");
    
    int maxRetries = 3;
    int retryCount = 0;
    notify:SmsResponse? finalResult = ();
    
    while retryCount < maxRetries && finalResult is () {
        notify:SmsResponse|error result = notifyClient.sendSms(
            to = "9471234567",
            message = "Important notification - please confirm receipt.",
            senderId = "NotifyDEMO"
        );
        
        if result is notify:SmsResponse {
            finalResult = result;
            io:println(string `✓ SMS sent successfully on attempt ${retryCount + 1}`);
        } else {
            retryCount += 1;
            io:println(string `✗ Attempt ${retryCount} failed: ${result.message()}`);
            
            if retryCount < maxRetries {
                io:println("Retrying...");
                // In real applications, add exponential backoff delay here
            }
        }
    }
    
    if finalResult is () {
        io:println("Failed to send SMS after all retry attempts");
    }
    
    // Example 3: Account balance monitoring
    io:println("\n=== Account Balance Monitoring ===");
    
    notify:AccountStatusResponse|error statusResult = notifyClient.getAccountStatus();
    
    if statusResult is notify:AccountStatusResponse && statusResult.data is notify:AccountStatusData {
        notify:AccountStatusData accountData = <notify:AccountStatusData>statusResult.data;
        decimal balance = accountData.accBalance;
        decimal lowBalanceThreshold = 100.0;
        
        io:println(string `Current balance: ${balance}`);
        
        if balance < lowBalanceThreshold {
            io:println("⚠️  Warning: Account balance is low!");
            
            // Send low balance notification to admin
            notify:SmsResponse|error alertResult = notifyClient.sendSms(
                to = "9471234567", // Admin phone number
                message = string `Alert: Notify.lk account balance is low (${balance}). Please top up.`,
                senderId = "NotifyDEMO"
            );
            
            if alertResult is notify:SmsResponse {
                io:println("Low balance alert sent to admin");
            }
        } else {
            io:println("✓ Account balance is sufficient");
        }
    }
    
    // Example 4: Message template system
    io:println("\n=== Message Template System ===");
    
    // Send welcome message using template
    string welcomeMessage = "Welcome Alice! Your account has been created successfully.";
    
    notify:SmsResponse|error templateResult = notifyClient.sendSms(
        to = "9471234567",
        message = welcomeMessage,
        senderId = "NotifyDEMO",
        contactInfo = {firstName: "Alice", lastName: "Cooper"}
    );
    
    if templateResult is notify:SmsResponse {
        io:println("✓ Template message sent successfully");
    } else {
        io:println("✗ Template message failed: " + templateResult.message());
    }
    
    // Example 5: Unicode message handling
    io:println("\n=== Unicode Message Handling ===");
    
    map<string> unicodeMessages = {
        "sinhala": "ආයුබෝවන්! ඔබගේ ගිණුම සාර්ථකව නිර්මාණය කර ඇත.",
        "tamil": "வணக்கம்! உங்கள் கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது.",
        "emoji": "🎉 Congratulations! You've won a prize! 🏆"
    };
    
    foreach string lang in unicodeMessages.keys() {
        string message = unicodeMessages[lang] ?: "";
        
        notify:SmsResponse|error unicodeResult = notifyClient.sendSms(
            to = "9471234567",
            message = message,
            senderId = "NotifyDEMO",
            messageType = notify:UNICODE
        );
        
        if unicodeResult is notify:SmsResponse {
            io:println(string `✓ ${lang} message sent: ${unicodeResult.status}`);
        } else {
            io:println(string `✗ ${lang} message failed: ${unicodeResult.message()}`);
        }
    }
}

// Helper function to validate phone numbers
function isValidPhoneNumber(string phoneNumber) returns boolean {
    // Basic validation for Sri Lankan phone numbers
    return phoneNumber.matches(re `^947[0-9]{8}$`);
}

// Helper function to truncate long messages
function truncateMessage(string message, int maxLength = 320) returns string {
    if message.length() <= maxLength {
        return message;
    }
    return message.substring(0, maxLength - 3) + "...";
}