import ballerina/io;
import ballerina/test;

// Test configuration - replace with your actual credentials for integration testing
const string TEST_USER_ID = "test_user_id";
const string TEST_API_KEY = "test_api_key";
const string TEST_PHONE = "9471234567";
const string TEST_SENDER = "NotifyDEMO";

// Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Starting Notify.lk integration tests...");
}

// Test client creation
@test:Config {}
function testClientCreation() {
    NotifyClient|error clientResult = createClient(TEST_USER_ID, TEST_API_KEY);
    test:assertTrue(clientResult is NotifyClient, "Client creation should succeed");
}

// Test client creation with custom base URL
@test:Config {}
function testClientCreationWithCustomUrl() {
    NotifyClient|error clientResult = createClient(TEST_USER_ID, TEST_API_KEY, "https://custom.api.url");
    test:assertTrue(clientResult is NotifyClient, "Client creation with custom URL should succeed");
}

// Test SMS sending (mock test - doesn't make actual API call)
@test:Config {}
function testSmsSendValidation() {
    NotifyClient|error clientResult = createClient(TEST_USER_ID, TEST_API_KEY);
    
    if clientResult is NotifyClient {
        // Test message length validation
        string longMessage = "This is a very long message that exceeds the 320 character limit. " +
                           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod " +
                           "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim " +
                           "veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea " +
                           "commodo consequat. Duis aute irure dolor in reprehenderit in voluptate " +
                           "velit esse cillum dolore eu fugiat nulla pariatur.";
        
        // This should fail due to message length
        SmsResponse|error result = clientResult.sendSms(TEST_PHONE, longMessage, TEST_SENDER);
        test:assertTrue(result is error, "Long message should return error");
        
        if result is error {
            test:assertTrue(result.message().includes("320 characters"), 
                          "Error should mention character limit");
        }
    } else {
        test:assertFail("Client creation failed");
    }
}

// Test contact info creation
@test:Config {}
function testContactInfoCreation() {
    ContactInfo contactInfo = {
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        address: "123 Main St",
        groupId: 1
    };
    
    test:assertEquals(contactInfo.firstName, "John", "First name should match");
    test:assertEquals(contactInfo.lastName, "Doe", "Last name should match");
    test:assertEquals(contactInfo.email, "john.doe@example.com", "Email should match");
    test:assertEquals(contactInfo.address, "123 Main St", "Address should match");
    test:assertEquals(contactInfo.groupId, 1, "Group ID should match");
}

// Test message type enum
@test:Config {}
function testMessageTypes() {
    test:assertEquals(NORMAL, "normal", "Normal message type should be 'normal'");
    test:assertEquals(UNICODE, "unicode", "Unicode message type should be 'unicode'");
}

// Test configuration record
@test:Config {}
function testNotifyConfig() {
    NotifyConfig config = {
        userId: "test_user",
        apiKey: "test_key"
    };
    
    test:assertEquals(config.userId, "test_user", "User ID should match");
    test:assertEquals(config.apiKey, "test_key", "API key should match");
    test:assertEquals(config.baseUrl, "https://app.notify.lk/api/v1", "Default base URL should be set");
}

// Test configuration with custom base URL
@test:Config {}
function testNotifyConfigWithCustomUrl() {
    NotifyConfig config = {
        userId: "test_user",
        apiKey: "test_key",
        baseUrl: "https://custom.url"
    };
    
    test:assertEquals(config.baseUrl, "https://custom.url", "Custom base URL should be set");
}

// After Suite Function
@test:AfterSuite
function afterSuiteFunc() {
    io:println("Notify.lk integration tests completed!");
}
