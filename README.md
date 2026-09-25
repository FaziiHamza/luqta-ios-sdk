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
pod 'LuqtaSDK', '~> 1.5.0'
```

### Swift Package Manager

In Xcode: **File > Add Package Dependencies** and enter:

```
https://github.com/FaziiHamza/luqta-ios-sdk
```

Or add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FaziiHamza/luqta-ios-sdk", from: "1.5.0")
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

// Complete a QR level with whatever the scanner read (takes the uid route
// when the text is an auto-completion link)
try await client.levels.completeQrScan(levelId, scanned: scannedText)

// Complete an image level — base64 data URI of a JPEG/PNG, at most 2 MB
try await client.levels.completeWithImage(
    levelId, imageUrl: "data:image/jpeg;base64,\(jpeg.base64EncodedString())"
)

// Survey: contest-wide questions, pick your level's block, submit answers.
// A skipped optional question is simply left out.
let survey = try await client.levels.getSurveyQuestions(contestId: contestId).forLevel(levelId)
try await client.levels.submitSurvey(contestId: contestId, levelId: levelId, answers: [
    SurveyAnswer(questionId: 12, selectedOptions: ["Yes"]),
    SurveyAnswer(questionId: 14, answerText: "Loved it"),
])

// Link task: start the server-side dwell, then claim once it is served
let start = try await client.levels.startLinkTask(levelId)   // LinkTaskStart
try await client.levels.complete(levelId, data: ["link": start.taskUrl ?? ""])

// QR auto-completion, from your deep-link handler after initializeUser
let scan = try await client.levels.completeQrByUid(url.absoluteString)

// Referrals: code to share, progress, and the friend's redeem
let invite = try await client.referrals.share(levelId: levelId)
let progress = try await client.referrals.progress(levelId: levelId)
try await client.referrals.redeem(referralCode: try ReferralApi.parseCode(url.absoluteString))

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

## Level Types & Validation

In preconfigured mode every level below plays with no wiring. Before any level
opens, a contest that has not started, a level whose `start_date` is ahead, or
one whose `level_timeline` has passed shows an "unavailable" dialog instead.
Each type then checks what it can on the device; the server stays the authority,
and its refusals are shown as localized copy (English and Arabic) by code.

| Level type | `level_type` | Checked on the device | Server refusals mapped |
|---|---|---|---|
| Text | `text` | Answer is not blank | — |
| QR | `qr` | Code is not blank | `INVALID_QR_CODE`, `NOT_A_QR_LEVEL`, `NOT_PARTICIPANT`, `LEVEL_NOT_STARTED`, `LEVEL_ENDED`, `LEVEL_ALREADY_COMPLETED` |
| Link | `link` | The link actually opened before Submit is accepted | — |
| Image | `image` | Camera present and permitted; resized to 1920 px, JPEG 85%, **≤ 2 MB** | — |
| Quiz | `quiz` | Server-driven | — |
| Client webhook | `client_webhook` | Every variable filled; `number` parses | — |
| Luqta webhook | `luqta_webhook` | Hosted URL opened before Submit | — |
| Survey | `survey`, `level_survey` | Required question blocks Next; `minimum_answers` (≥ 1) before Submit | `not_participant`, `level_already_completed`, `required_question_missing`, `below_minimum_answers`, `not_a_survey_level`, `answer_not_in_level` |
| Link task | `link_task`, `level_link_task`, `linktask` | URL needs scheme + host; dwell ≥ 10 s; leaving restarts it | `link_not_started`, `link_timer_not_elapsed`, `level_not_started`, `level_ended`, `level_already_completed`, `not_participant` |
| Referral | `referral`, `level_referral` | Code read from digits, spaced/dashed digits or a full link | `referral_unavailable`, `self_referral`, `already_redeemed`, `referral_limit_reached`, `referral_code_inactive`, `invalid_referral_code` |
| Geolocation / AR | `level_geolocation` | Inside the point's radius before the camera opens | — |

**Link task.** `link_open_mode: in_app` (the default) opens the page in an SDK
WebView: the timer starts once the page has loaded and the claim is made on the
page. `external` opens Safari. The server re-checks the elapsed time on claim.

**Referral.** The SDK hands out an 8-digit code; your app owns the link, because
it has to open *your* app:

```swift
LuqtaConfig(apiKey: "...", appId: "...",
            referralLinkBuilder: { code in "https://myapp.example/invite?ref=\(code)" })
```

Redeem in your deep-link handler **after** sign-in and `initializeUser`.

**QR auto-completion.** A printed code encodes a link carrying `levels.uid`;
the phone's camera opens your app and `completeQrByUid` completes the level.
Also after `initializeUser`. A scan never auto-joins a contest.

Survey, link-task and referral levels end on the level-completed dialog, or the
contest one when it was the last level.

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

See the [example app](https://github.com/FaziiHamza/luqta-sdk/tree/main/examples/ios_example_swift): a generic demo host configured on the device (App ID, API key, Dev/Live, user identifier, branding, language), with sign-in, sign-up and the SDK's contests embedded and full screen.

## What's New in 1.5.0

Survey, link-task, referral and QR auto-completion levels; link tasks in an
in-app page; intact image uploads; the detail page no longer empties after a
join; brand colour on every button. **Breaking:** `startLinkTask` returns
`LinkTaskStart` instead of `Int?`. Full notes in the
[changelog](https://github.com/FaziiHamza/luqta-sdk/blob/main/ios-sdk-swift/CHANGELOG.md).

## License

MIT License — See [LICENSE](LICENSE) for details.

## Support

- Email: support@luqta.com
- Issues: [GitHub Issues](https://github.com/FaziiHamza/luqta-ios-sdk/issues)
