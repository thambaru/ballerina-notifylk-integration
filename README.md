# Notify.lk Ballerina Integration

A Ballerina package for integrating with the [Notify.lk SMS gateway](https://notify.lk) to send SMS messages and query account status from Ballerina applications.

This package mirrors the functionality of the official [Notify.lk PHP SDK](https://github.com/notifylk/notify-php) and provides a clean, type-safe API for Ballerina developers.

## Features

- ✅ Send SMS messages to any phone number
- ✅ Support for custom sender IDs
- ✅ Unicode message support
- ✅ Contact information management
- ✅ Account status and balance checking
- ✅ Type-safe API with comprehensive error handling
- ✅ Configurable base URL for testing

## Installation

Add the package to your `Ballerina.toml`:

```toml
[[dependency]]
org = "thambaru"
name = "notifylk_integration"
version = "0.1.0"
```

## Quick Start

### 1. Import the Package

```ballerina
import thambaru/notifylk_integration as notify;
```

### 2. Create a Client

```ballerina
// Create client with your Notify.lk credentials
notify:NotifyClient|error client = notify:createClient("your_user_id", "your_api_key");

if client is notify:NotifyClient {
    // Client ready to use
} else {
    // Handle client creation error
    io:println("Failed to create client: " + client.message());
}
```

### 3. Send SMS

```ballerina
import ballerina/io;

public function main() returns error? {
    // Create client
    notify:NotifyClient client = check notify:createClient("your_user_id", "your_api_key");
    
    // Send simple SMS
    notify:SmsResponse response = check client.sendSms(
        to = "9471234567",
        message = "Hello from Ballerina!",
        senderId = "NotifyDEMO"
    );
    
    io:println("SMS sent successfully: " + response.message);
}
```

## API Reference

### Client Creation

#### `createClient(userId, apiKey, baseUrl?)`

Creates a new Notify.lk SMS client.

**Parameters:**
- `userId` (string) - Your Notify.lk user ID from settings page
- `apiKey` (string) - Your Notify.lk API key from settings page  
- `baseUrl` (string, optional) - Custom API base URL (default: https://app.notify.lk/api/v1)

**Returns:** `NotifyClient|error`

### SMS Operations

#### `sendSms(to, message, senderId, contactInfo?, messageType?)`

Sends an SMS message to a phone number.

**Parameters:**
- `to` (string) - Phone number in 9471XXXXXXX format
- `message` (string) - SMS text (max 320 characters)
- `senderId` (string) - Sender ID (use "NotifyDEMO" for testing)
- `contactInfo` (ContactInfo, optional) - Contact information to save
- `messageType` (MessageType, optional) - Message type (NORMAL or UNICODE)

**Returns:** `SmsResponse|error`

#### `getAccountStatus()`

Retrieves account status and balance information.

**Returns:** `AccountStatusResponse|error`

### Data Types

#### `ContactInfo`

Optional contact information for SMS recipients:

```ballerina
notify:ContactInfo contactInfo = {
    firstName: "John",
    lastName: "Doe", 
    email: "john@example.com",
    address: "123 Main St",
    groupId: 1
};
```

#### `MessageType`

SMS message type enumeration:
- `NORMAL` - Regular SMS messages
- `UNICODE` - Unicode SMS messages for special characters

#### `SmsResponse`

Response from SMS send operation:

```ballerina
type SmsResponse record {|
    string status;    // "success" or "error"
    string message;   // Response message
    json? data;       // Additional response data
|};
```

#### `AccountStatusResponse`

Response from account status check:

```ballerina
type AccountStatusResponse record {|
    string status;
    AccountStatusData? data;
|};

type AccountStatusData record {|
    boolean active;      // Account active status
    decimal accBalance;  // Account balance
|};
```

## Examples

### Send SMS with Contact Information

```ballerina
import ballerina/io;
import thambaru/notifylk_integration as notify;

public function main() returns error? {
    notify:NotifyClient client = check notify:createClient("user_id", "api_key");
    
    // Contact information to save
    notify:ContactInfo contact = {
        firstName: "Jane",
        lastName: "Smith",
        email: "jane@example.com",
        groupId: 1
    };
    
    // Send SMS with contact info
    notify:SmsResponse response = check client.sendSms(
        to = "9471234567",
        message = "Welcome to our service!",
        senderId = "MyCompany",
        contactInfo = contact,
        messageType = notify:NORMAL
    );
    
    io:println("SMS Response: " + response.status);
}
```

### Send Unicode SMS

```ballerina
import ballerina/io;
import thambaru/notifylk_integration as notify;

public function main() returns error? {
    notify:NotifyClient client = check notify:createClient("user_id", "api_key");
    
    // Send SMS with Unicode characters
    notify:SmsResponse response = check client.sendSms(
        to = "9471234567",
        message = "සුභ උපන්දිනයක්! 🎉",  // Sinhala text with emoji
        senderId = "NotifyDEMO",
        messageType = notify:UNICODE
    );
    
    io:println("Unicode SMS sent: " + response.message);
}
```

### Check Account Status

```ballerina
import ballerina/io;
import thambaru/notifylk_integration as notify;

public function main() returns error? {
    notify:NotifyClient client = check notify:createClient("user_id", "api_key");
    
    // Check account status
    notify:AccountStatusResponse status = check client.getAccountStatus();
    
    if status.data is notify:AccountStatusData {
        io:println("Account Active: " + status.data.active.toString());
        io:println("Balance: " + status.data.accBalance.toString());
    }
}
```

### Error Handling

```ballerina
import ballerina/io;
import thambaru/notifylk_integration as notify;

public function main() {
    notify:NotifyClient|error clientResult = notify:createClient("user_id", "api_key");
    
    if clientResult is error {
        io:println("Client creation failed: " + clientResult.message());
        return;
    }
    
    notify:NotifyClient client = clientResult;
    
    // Try to send SMS with error handling
    notify:SmsResponse|error smsResult = client.sendSms(
        to = "9471234567",
        message = "Test message",
        senderId = "NotifyDEMO"
    );
    
    if smsResult is error {
        io:println("SMS send failed: " + smsResult.message());
    } else {
        io:println("SMS sent successfully: " + smsResult.status);
    }
}
```

## Configuration

### Environment Variables

For production use, store your credentials as environment variables:

```bash
export NOTIFY_USER_ID="your_user_id"
export NOTIFY_API_KEY="your_api_key"
```

```ballerina
import ballerina/os;
import thambaru/notifylk_integration as notify;

public function main() returns error? {
    string userId = os:getEnv("NOTIFY_USER_ID");
    string apiKey = os:getEnv("NOTIFY_API_KEY");
    
    notify:NotifyClient client = check notify:createClient(userId, apiKey);
    // Use client...
}
```

## Testing

Run the test suite:

```bash
bal test
```

For integration testing with real API calls, update the test credentials in `tests/lib_test.bal`.

## Important Notes

> **⚠️ OTP Content Warning**  
> Please avoid sending OTP content with the DEMO sender name. Get your own Sender ID approved first, otherwise there's a risk of getting your account suspended.

> **📱 Phone Number Format**  
> Use the format `9471XXXXXXX` for Sri Lankan phone numbers for best delivery rates.

> **📝 Message Length**  
> SMS messages are limited to 320 characters. Longer messages will return an error.

## API Endpoints

This package uses the following Notify.lk API endpoints:

| Feature | Endpoint | Method |
|---------|----------|--------|
| Send SMS | `/send` | POST |
| Account Status | `/status` | GET |

Base URL: `https://app.notify.lk/api/v1`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- [Notify.lk Official Documentation](https://notify.lk/docs)
- [Notify.lk PHP SDK](https://github.com/notifylk/notify-php)
- [Ballerina Documentation](https://ballerina.io/learn/)

## Changelog

### v0.1.0
- Initial release
- SMS sending functionality
- Account status checking
- Contact information management
- Unicode message support
- Comprehensive error handling
