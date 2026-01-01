# Copilot Instructions for Ballerina Notify.lk Package

This file provides guidance and examples to help GitHub Copilot (or other AI assistants) generate useful, context-aware code for the Ballerina package that wraps the Notify.lk SMS API.

---

## 📦 Package Purpose

The Ballerina **notify.lk** package enables developers to integrate with the **Notify.lk SMS gateway** to send SMS messages and query account status from Ballerina applications.  
It mirrors the official **PHP SDK** and **REST API endpoints** provided by Notify.lk. :contentReference[oaicite:0]{index=0}

---

## 🚀 Key Concepts

### 🔑 Authentication
All API requests require:

- `userId` — your Notify.lk account user ID
- `apiKey` — your API key

These must be passed as query parameters or form data to each endpoint. :contentReference[oaicite:1]{index=1}

---

## 🧠 Copilot Guidance Prompts

When writing code, Copilot should aim to:

### 1️⃣ Create a Client

```markdown
# Suggest generating a Ballerina client record for Notify.lk
# e.g., `NotifyClient` with fields `string userId`, `string apiKey`.

Define a client with default baseUrl: "https://app.notify.lk/api/v1"
````

### 2️⃣ Provide a Method to Send SMS

```markdown
# Provide an example function signature:
# public function sendSms(NotifyClient client, string to, string message, string senderId, string? contactFirstName = (), ...)
```

Copilot should generate Ballerina code that:

* Sends SMS using the `/send` endpoint
* Accepts required and optional parameters
* Returns a deserialized JSON response record

Include example usage comments.

````

### 3️⃣ Provide a Method to Retrieve Account Status

```markdown
# Provide an example function signature:
# public function getAccountStatus(NotifyClient client)

Suggest using `GET /status?

Example response:
{
  status: "success",
  data: {
    active: true,
    acc_balance: float
  }
}
````

### 4️⃣ Handle Responses Properly

```markdown
# Generate response record types for:
# - SMS send success/failure
# - Account status response

Suggest error handling:
# if the API returns failure, throw a Ballerina error with message.
```

### 5️⃣ Add Documentation Snippets

For every user-facing function, Copilot should produce:

````markdown
# Add doc comments:
# e.g., ```

## 📝 Example API Usage (for Copilot)

### Send SMS

```ballerina
string to = "9471XXXXXXX";
string msg = "Hello from Ballerina!";
string sender = "NotifyDEMO";

var response = client->sendSms(to, msg, sender);
````

### Check Account Status

```ballerina
var status = client->getAccountStatus();
```

---

## 💡 Style & Best Practices

* Use **readonly client configuration** where possible.
* Represent JSON responses with **typed records**.
* Handle possible error states gracefully using Ballerina's error model.
* Include parameter validation where sensible (e.g., phone formats).
* Generate tests for happy and failure paths, analogous to the PHP SDK's test suite. ([GitHub][1])

---

## 📄 Reference API Endpoints

Use these authoritative docs when generating code:

| Feature        | Endpoint  | Method   |
| -------------- | --------- | -------- |
| Send SMS       | `/send`   | GET/POST |
| Account Status | `/status` | GET      |

Parameters such as `user_id`, `api_key`, `sender_id`, `to`, `message`, and optional contact info should be mapped to Ballerina parameters. ([Notify.lk API Documentation][2])

## 📚 Further Help

For more detailed Notify.lk docs, visit:

* Official Notify.lk API docs (Direct Endpoints) ([Notify.lk API Documentation][2])
* Notify.lk GitHub PHP SDK (for patterns to mirror) ([GitHub][3])

```
/Users/thambaru/Development/ballerina/notifylk-integration/notify-php-masterThis folder contains the PHP integration for a SMS service called notifylk. I want to build a Ballerina package for this.contains additional details. Start developing the package.