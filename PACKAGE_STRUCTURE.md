# Notify.lk Ballerina Package Structure

This document outlines the structure and components of the Notify.lk Ballerina integration package.

## Package Files

### Core Implementation
- **`notifylk_integration.bal`** - Main package implementation containing:
  - `NotifyClient` class for SMS operations
  - Type definitions for requests and responses
  - `createClient()` helper function
  - SMS sending and account status functionality

### Configuration
- **`Ballerina.toml`** - Package configuration with dependencies
- **`.devcontainer.json`** - Development container configuration

### Documentation
- **`README.md`** - Comprehensive package documentation with examples
- **`PACKAGE_STRUCTURE.md`** - This file describing package structure
- **`.github/copilot-instructions.md`** - GitHub Copilot guidance for the package

### Examples
- **`example.bal`** - Runnable example demonstrating all package features
- **`examples/basic_usage.bal`** - Basic usage examples (requires package import)
- **`examples/advanced_usage.bal`** - Advanced patterns like bulk SMS and retry logic

### Tests
- **`tests/lib_test.bal`** - Comprehensive test suite covering:
  - Client creation and configuration
  - Message validation
  - Type definitions
  - Error handling

### Reference Implementation
- **`notify-php-master/`** - Original PHP SDK for reference and API understanding

## Key Components

### 1. NotifyClient Class
The main client class providing SMS functionality:
```ballerina
public class NotifyClient {
    public function sendSms(...) returns SmsResponse|error;
    public function getAccountStatus() returns AccountStatusResponse|error;
}
```

### 2. Type Definitions
- `NotifyConfig` - Client configuration
- `ContactInfo` - Optional contact information
- `SmsResponse` - SMS send response
- `AccountStatusResponse` - Account status response
- `MessageType` - Enum for message types (NORMAL, UNICODE)

### 3. Helper Functions
- `createClient()` - Convenient client creation function

## Usage Patterns

### Basic Usage
```ballerina
import thambaru/notifylk_integration as notify;

notify:NotifyClient client = check notify:createClient("userId", "apiKey");
notify:SmsResponse response = check client.sendSms("9471234567", "Hello!", "NotifyDEMO");
```

### With Contact Information
```ballerina
notify:ContactInfo contact = {firstName: "John", lastName: "Doe"};
notify:SmsResponse response = check client.sendSms("9471234567", "Hello John!", "NotifyDEMO", contact);
```

### Unicode Messages
```ballerina
notify:SmsResponse response = check client.sendSms("9471234567", "සුභ උපන්දිනයක්!", "NotifyDEMO", messageType = notify:UNICODE);
```

## Testing

Run tests with:
```bash
bal test
```

Run example with:
```bash
bal run example.bal
```

## API Endpoints

The package integrates with these Notify.lk API endpoints:
- `POST /send` - Send SMS messages
- `GET /status` - Get account status and balance

Base URL: `https://app.notify.lk/api/v1`

## Dependencies

- `ballerina/http` - HTTP client functionality
- `ballerina/url` - URL encoding utilities
- `ballerina/io` - Input/output operations (examples)
- `ballerina/os` - Environment variable access (examples)
- `ballerina/test` - Testing framework

## Error Handling

The package provides comprehensive error handling:
- Message length validation (320 character limit)
- HTTP status code checking
- Type-safe error responses
- Detailed error messages

## Security Considerations

- Store credentials in environment variables
- Use HTTPS for all API calls
- Validate phone number formats
- Handle API responses securely