import ballerina/http;
import ballerina/url;

# Configuration for Notify.lk SMS client
#
# + userId - API User ID from Notify.lk settings page
# + apiKey - API Key from Notify.lk settings page  
# + baseUrl - Base URL for Notify.lk API (default: https://app.notify.lk/api/v1)
public type NotifyConfig record {|
    string userId;
    string apiKey;
    string baseUrl = "https://app.notify.lk/api/v1";
|};

# Contact information for SMS recipient (optional)
#
# + firstName - Contact first name
# + lastName - Contact last name
# + email - Contact email address
# + address - Contact physical address
# + groupId - Group ID to associate the contact with
public type ContactInfo record {|
    string? firstName = ();
    string? lastName = ();
    string? email = ();
    string? address = ();
    int? groupId = ();
|};

# SMS message type
public enum MessageType {
    NORMAL = "normal",
    UNICODE = "unicode"
}

# SMS send response from Notify.lk API
#
# + status - Response status (success/error)
# + message - Response message
# + data - Additional response data
public type SmsResponse record {|
    string status;
    string message;
    json? data = ();
|};

# Account status response from Notify.lk API
#
# + status - Response status
# + data - Account status data
public type AccountStatusResponse record {|
    string status;
    AccountStatusData? data = ();
|};

# Account status data
#
# + active - Whether account is active
# + accBalance - Account balance
public type AccountStatusData record {|
    boolean active;
    decimal accBalance;
|};

# Notify.lk SMS client
#
# + config - Client configuration
# + httpClient - HTTP client for API calls
public class NotifyClient {
    private final NotifyConfig config;
    private final http:Client httpClient;

    # Initialize a new Notify.lk SMS client
    #
    # + config - Client configuration with userId and apiKey
    # + return - New NotifyClient instance or error
    public function init(NotifyConfig config) returns error? {
        self.config = config.cloneReadOnly();
        self.httpClient = check new (self.config.baseUrl);
    }

    # Send SMS to a phone number
    #
    # + to - Phone number to send SMS (format: 9471XXXXXXX)
    # + message - SMS message text (max 320 characters)
    # + senderId - Sender ID (use "NotifyDEMO" if you don't have your own)
    # + contactInfo - Optional contact information to save
    # + messageType - Message type (normal or unicode)
    # + return - SMS response or error
    public function sendSms(string to, string message, string senderId, 
                           ContactInfo? contactInfo = (), 
                           MessageType messageType = NORMAL) returns SmsResponse|error {
        
        // Validate message length
        if message.length() > 320 {
            return error("Message length cannot exceed 320 characters");
        }

        // Prepare form data
        map<string> formData = {
            "user_id": self.config.userId,
            "api_key": self.config.apiKey,
            "message": message,
            "to": to,
            "sender_id": senderId,
            "type": messageType
        };

        // Add optional contact information
        if contactInfo is ContactInfo {
            if contactInfo.firstName is string {
                formData["contact_fname"] = <string>contactInfo.firstName;
            }
            if contactInfo.lastName is string {
                formData["contact_lname"] = <string>contactInfo.lastName;
            }
            if contactInfo.email is string {
                formData["contact_email"] = <string>contactInfo.email;
            }
            if contactInfo.address is string {
                formData["contact_address"] = <string>contactInfo.address;
            }
            if contactInfo.groupId is int {
                formData["contact_group"] = (<int>contactInfo.groupId).toString();
            }
        }

        // Make API call
        http:Response response = check self.httpClient->post("/send", formData);
        
        // Handle response
        if response.statusCode == 200 {
            json responseJson = check response.getJsonPayload();
            return check responseJson.cloneWithType(SmsResponse);
        } else {
            return error(string `SMS send failed with status code: ${response.statusCode}`);
        }
    }

    # Get account status and balance
    #
    # + return - Account status response or error
    public function getAccountStatus() returns AccountStatusResponse|error {
        // Prepare query parameters
        string queryParams = check url:encode(self.config.userId, "UTF-8") + "&api_key=" + 
                           check url:encode(self.config.apiKey, "UTF-8");
        
        // Make API call
        http:Response response = check self.httpClient->get("/status?user_id=" + queryParams);
        
        // Handle response
        if response.statusCode == 200 {
            json responseJson = check response.getJsonPayload();
            return check responseJson.cloneWithType(AccountStatusResponse);
        } else {
            return error(string `Account status check failed with status code: ${response.statusCode}`);
        }
    }
}

# Create a new Notify.lk SMS client
#
# + userId - API User ID from Notify.lk settings page
# + apiKey - API Key from Notify.lk settings page
# + baseUrl - Optional custom base URL (default: https://app.notify.lk/api/v1)
# + return - New NotifyClient instance or error
public function createClient(string userId, string apiKey, string? baseUrl = ()) returns NotifyClient|error {
    NotifyConfig config = {
        userId: userId,
        apiKey: apiKey,
        baseUrl: baseUrl ?: "https://app.notify.lk/api/v1"
    };
    
    return new NotifyClient(config);
}
