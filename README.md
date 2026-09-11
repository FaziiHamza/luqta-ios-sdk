# LuqtaSDK for iOS

Official iOS SDK for the [Luqta](https://github.com/FaziiHamza/luqta-ios-sdk) API — Add contests, quizzes, rewards, and gamification to your iOS app.

[![CocoaPods](https://img.shields.io/cocoapods/v/LuqtaSDK.svg)](https://cocoapods.org/pods/LuqtaSDK)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2015.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Installation

### CocoaPods

```ruby
pod 'LuqtaSDK', '~> 1.4.0'
```

### Swift Package Manager

In Xcode: **File > Add Package Dependencies** and enter:

```
https://github.com/FaziiHamza/luqta-ios-sdk
```

Or add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FaziiHamza/luqta-ios-sdk", from: "1.4.0")
]
```

---

## Two Integration Modes

| Mode | Description | Effort |
|------|-------------|--------|
| **Preconfigured** | Complete UI out of the box — just call `render()` | Minimal |
| **Custom** | Use APIs to build your own UI | Full control |

---

## Mode 1: Preconfigured (Complete UI)

Get a full-featured contest experience with **one method call**. The SDK renders all screens, handles navigation, API calls, and state.

### Step-by-Step

```swift
import SwiftUI
import LuqtaSDK

struct ContestsView: View {
    @State private var client: LuqtaClient?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let error = error {
                Text(error).foregroundColor(.red)
            } else if let client = client {
                // One line — renders the entire contest UI
                client.render()
            }
        }
        .task {
            await setup()
        }
    }

    func setup() async {
        do {
            // 1. Create client in preconfigured mode
            let config = LuqtaConfig(
                mode: .preconfigured,
                apiKey: "your-api-key",
                appId: "your-app-id",
                branding: LuqtaBranding(
                    primaryColor: "#9333ea",
                    secondaryColor: "#4f46e5"
                ),
                locale: "en",
                onAction: { action in print("Action: \(action)") },
                onError: { error in print("Error: \(error)") }
            )
            let newClient = try LuqtaClient(config: config)

            // 2. Initialize SDK
            _ = try await newClient.initializeSdk()

            // 3. Initialize user
            try await newClient.syncAndInitializeUser(UserProfile(
                name: "John Doe",
                email: "john@example.com",
                policyAccept: true
            ))

            self.client = newClient
            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
}
```

### What `render()` Includes

- Contest carousel with banner images
- Contest detail pages with levels and progress
- Level completion flows — Text, QR code, Link, Image upload
- Quiz interface with timer and scoring
- Congratulations screen with animations
- Private contest access code entry
- Pull-to-refresh and countdown timers
- Full navigation and error handling

### Session Restore (Skip Login on Relaunch)

```swift
// Tokens are stored in Keychain automatically
if client.tryRestoreSession() {
    // Restored — no API call needed
} else {
    _ = try await client.initializeSdk()
}
```

---

## Mode 2: Custom (Build Your Own UI)

Use the SDK APIs directly to fetch data and build your own interface.

### Setup

```swift
import LuqtaSDK

// 1. Create client (custom mode is default)
let client = try LuqtaClient(config: LuqtaConfig(
    apiKey: "your-api-key",
    appId: "your-app-id"
))

// 2. Initialize SDK
_ = try await client.initializeSdk()

// 3. Set user and initialize
try client.setUser(LuqtaUser(email: "john@example.com"))
try await client.initializeUser()

// Or sync + initialize in one call:
try await client.syncAndInitializeUser(UserProfile(
    name: "John Doe",
    email: "john@example.com",
    policyAccept: true
))
```

### Contests API

```swift
// Get all contests (paginated)
let response = try await client.contests.getAll(page: 1, perPage: 10)
// response.data.items — array of contests
// response.data.hasNextPage — pagination

// Trending / Premium / Recent
let trending = try await client.contests.getTrending()
let premium = try await client.contests.getPremium()
let recent = try await client.contests.getRecent()

// Participate in a contest
let result = try await client.contests.participate(contestId)

// Participate with access code (private contest)
let result = try await client.contests.participate(contestId, accessCode: "ABC123")

// Get contest progress and details
let progress = try await client.contests.getProgress(contestId)
let compete = try await client.contests.compete(contestId)
let details = try await client.getContestDetailsProgress(contestId)

// Contest history
let history = try await client.contests.getHistory()
```

### Levels API

```swift
// Complete a text level
try await client.levels.complete(levelId, data: ["textContent": "my answer"])

// Complete a link level
try await client.levels.complete(levelId, data: ["link": "https://example.com"])

// Complete a QR level
try await client.levels.complete(levelId, data: ["qrData": "scanned-content"])

// Complete an image level
try await client.levels.completeWithImage(levelId, imageUrl: "https://...")

// Complete a client_webhook level — dedicated endpoint, not complete(_:data:)
try await client.levels.completeClientWebhook(levelId, variables: [
    ["variable_name": "email", "data_type": "string", "value": "a@b.c"],
    ["variable_name": "policy", "data_type": "boolean", "value": true],
])

// Complete a luqta_webhook level — marks the hosted flow as visited
try await client.levels.complete(levelId, data: [
    "luqta_webhook_url": level.luqtaWebhookUrl ?? "",
    "visited": true,
])

// Mark level as in-progress
try await client.levels.updateProgress(levelId)

// Get congratulation data
try await client.levels.getCongratulation(levelId: levelId, contestId: contestId)

// Scan QR code
try await client.levels.scanQR("qr-data")
```

### Quiz API

```swift
// Start quiz
let attempt = try await client.quiz.start(quizId)

// Submit answer
try await client.quiz.submitAnswer(
    attemptId: attemptId,
    questionId: questionId,
    optionId: selectedOptionId
)

// Complete quiz
let result = try await client.quiz.submit(attemptId)
```

### Rewards API

```swift
// Get available rewards
let rewards = try await client.rewards.getList()

// Get user earnings
let earnings = try await client.rewards.getEarnings()

// Redeem a reward
try await client.rewards.redeem(rewardId, points: 100)

// Reward history
let history = try await client.rewards.getHistory()

// Prize history
let prizes = try await client.rewards.getPrizeHistory()
```

### Notifications API

```swift
// Get notifications
let notifications = try await client.notifications.getAll()

// Mark as read
try await client.notifications.markAsRead([id1, id2])

// Update settings
try await client.notifications.updateSettings(["push_enabled": true])
```

### Profile API

```swift
// Get profile
let profile = try await client.profile.get()

// Get activities and progress
let activities = try await client.profile.getActivities()
let progress = try await client.profile.getProgress()

// Submit feedback
try await client.profile.submitFeedback(rating: 5, feedback: "Great!")

// Delete account
try await client.profile.deleteAccount()
```

### Raw HTTP Methods

```swift
let data = try await client.get("/endpoint", params: ["key": "value"])
let data = try await client.post("/endpoint", body: ["key": "value"])
let data = try await client.put("/endpoint", body: ["key": "value"])
let data = try await client.delete("/endpoint")
let data = try await client.patch("/endpoint", body: ["key": "value"])
```

---

## Configuration

### LuqtaConfig

```swift
LuqtaConfig(
    mode: .preconfigured,           // .preconfigured or .custom (default)
    apiKey: "your-api-key",         // Required
    appId: "your-app-id",          // Required
    production: false,              // Default: false (use staging)
    user: LuqtaUser(               // Optional: set user at init
        email: "user@example.com"
    ),
    baseURL: nil,                   // Optional: override base URL
    timeout: 30,                    // Request timeout in seconds
    headers: ["X-Custom": "val"],   // Custom headers
    branding: LuqtaBranding(        // UI customization
        primaryColor: "#9333ea",
        secondaryColor: "#4f46e5"
    ),
    locale: "en",                   // "en" or "ar"
    rtl: false,                     // Right-to-left layout
    onAction: { action in },        // Action callback
    onError: { error in }           // Error callback
)
```

### LuqtaUser

```swift
// By email
LuqtaUser(email: "user@example.com")

// By phone (international format with +)
LuqtaUser(phoneNumber: "+923147940690")

// Both
LuqtaUser(email: "user@example.com", phoneNumber: "+923147940690")
```

### UserProfile

```swift
UserProfile(
    name: "John Doe",
    email: "john@example.com",
    phoneNumber: "+923147940690",
    dob: "1990-01-01",
    gender: "male",
    country: "PK",
    verified: true,
    imageUrl: "https://...",
    interestedIn: ["sports", "music"],
    policyAccept: true
)
```

### LuqtaBranding

```swift
LuqtaBranding(
    primaryColor: "#9333ea",        // Hex color
    secondaryColor: "#4f46e5",
    backgroundColor: "#ffffff",
    textColor: "#111827",
    logoUrl: "https://...",
    appName: "My App",
    borderRadius: 8,
    fontFamily: nil
)
```

---

## Pre-built Widgets

Use these SwiftUI views in custom mode:

| Widget | Description |
|--------|-------------|
| `ContestsScreen` | Full contests listing with carousel |
| `ContestDetailScreen` | Contest detail with levels and progress |
| `ContestCard` | Single contest card |
| `LevelItemView` | Level row with status |
| `QuizWidget` | Quiz with timer and scoring |
| `TextLevelView` | Text input level |
| `QRLevelView` | QR code scanner level |
| `LinkLevelView` | Link visit level |
| `ImageLevelView` | Image upload level |
| `ClientWebhookLevelView` | Client-webhook level — dynamic form |
| `LuqtaWebhookLevelView` | Luqta-webhook level — participant id + link |
| `AccessCodeSheet` | Private contest access code input |
| `CongratulationDialog` | Animated completion celebration |
| `LuqtaToast` | Toast notification |
| `ShimmerView` | Loading shimmer animation |
| `RemoteImage` | Async image loader |

---

## Theming

### Set at Init

```swift
LuqtaConfig(
    branding: LuqtaBranding(
        primaryColor: "#9333ea",
        secondaryColor: "#6366f1"
    )
)
```

### Update at Runtime

```swift
client.setBranding(LuqtaBranding(primaryColor: "#FF5722"))
```

---

## Localization

| Language | Code | RTL |
|----------|------|-----|
| English | `en` | No |
| Arabic | `ar` | Yes |

```swift
// At init
LuqtaConfig(locale: "ar", rtl: true)

// At runtime
client.setLocale("ar")
client.setRtl(true)
```

---

## Error Handling

```swift
do {
    _ = try await client.initializeSdk()
} catch let error as LuqtaError {
    print(error.code)    // "SDK_INIT_FAILED"
    print(error.message) // Human-readable message
    print(error.status)  // HTTP status (optional)
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `MISSING_API_KEY` | API key not provided |
| `MISSING_APP_ID` | App ID not provided |
| `SDK_INIT_FAILED` | SDK initialization failed |
| `SDK_NOT_INITIALIZED` | Call initializeSdk() first |
| `USER_INIT_FAILED` | User initialization failed |
| `USER_NOT_INITIALIZED` | Call initializeUser() first |
| `USER_NOT_SYNCED` | User needs sync first |
| `MISSING_USER_IDENTIFIER` | Email or phone required |
| `INVALID_EMAIL_FORMAT` | Bad email format |
| `INVALID_PHONE_FORMAT` | Bad phone format |
| `USER_SYNC_FAILED` | Profile sync failed |
| `REQUEST_FAILED` | API request failed |
| `TIMEOUT` | Request timed out |
| `NETWORK_ERROR` | No connection |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

---

## Client Methods Reference

| Method | Description |
|--------|-------------|
| `initializeSdk()` | Initialize SDK with API key |
| `initializeUser()` | Initialize user session |
| `syncUser(profile)` | Sync user profile to backend |
| `syncAndInitializeUser(profile)` | Sync + initialize in one call |
| `setUser(user)` | Set user (email or phone) |
| `tryRestoreSession()` | Restore from Keychain |
| `isSdkReady()` | SDK initialized? |
| `isInitialized()` | User initialized? |
| `clearUserToken()` | Logout user |
| `render()` | Get preconfigured SwiftUI view |
| `setBranding(branding)` | Update UI branding |
| `setLocale(locale)` | Change language |
| `setRtl(bool)` | Toggle RTL layout |
| `setProduction(bool)` | Switch environment |
| `getSecurityStatus()` | Debug security info |

---

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

## Example App

See the [example app](https://github.com/FaziiHamza/luqta-sdk/tree/main/examples/ios_example_swift) for a complete implementation with login, signup, and contest rendering.

## License

MIT License — See [LICENSE](LICENSE) for details.

## Support

- Email: support@luqta.com
- Issues: [GitHub Issues](https://github.com/FaziiHamza/luqta-ios-sdk/issues)
