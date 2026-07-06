# ParkPing — iOS Development Guide

> **App Name**: ParkPing — Parking Timer & Reminder
> **Bundle ID**: com.zzoutuo.ParkPing
> **Minimum iOS**: 17.0
> **Target Market**: United States (English)
> **Slogan**: "One tap. One time. No subscription. Ever."

---

## Executive Summary

**ParkPing** is a minimalist parking timer and reminder app for iOS that solves a $2B/year pain point in the US market: parking tickets caused by forgetting meter expiration. Unlike incumbent apps (PayByPhone, ParkMobile) that force $3-5/month subscriptions and bloated account/credit-card flows, ParkPing is a **one-time-purchase, no-account, no-tracking** utility that opens instantly to a giant START button.

### Product Vision
A parking app that respects users: zero friction, zero subscriptions, zero tracking. Just tap START, see the countdown on Dynamic Island / Lock Screen, get a gentle warning 5 minutes before expiry, and tap "I'm Back" when done. The app fades into the background and never pesters the user.

### Key Differentiators
1. **Anti-subscription positioning** — $3.99 one-time vs. $36-60/year competitors
2. **Zero account / zero network** — fully local, privacy-first
3. **Live Activity + Dynamic Island** — countdown visible without unlocking
4. **One-tap start** — default 2-hour timer, no setup screens
5. **Full feature integration** — timer + find-car + street-sweeping + Watch + Siri in one app (no competitor covers all)
6. **Modern stack** — Swift 6, SwiftUI, SwiftData, ActivityKit, WidgetKit, AppIntents, StoreKit 2

### Target Audience
- US urban commuters (~200M population)
- Drivers aged 18-55 who pay for street/meter parking
- Anti-subscription sentiment (60% of US users per Reddit research)

---

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **PayByPhone** | Established, payment integration | $3-5/month subscription, account + credit card required, 50MB app, bloated | One-time $3.99, no account, instant start |
| **ParkMobile** | Wide coverage | Subscription, unauthorized charges reported, refund issues, towing despite payment | Local reliable timer, no payment integration risk |
| **SpotHero** | Free, parking reservation | Focus on lot booking, not street meter timing | Street-parking-first, Live Activity |
| **SpotClock** | Live Activity, walking directions | Subscription "Pro", limited free tier | One-time purchase, no recurring billing |
| **overthere** | Photo-based memory, widgets, multi-language | No Dynamic Island focus, IAP model | Dynamic Island + Siri + Watch integration |
| **ParkClock** | Trial + IAP | Trial model breeds distrust | Permanent free basic version |
| **Car Park Timer (KZ)** | Cheap one-time $1 | Regional (Kazakhstan), no street sweeping | US-localized, street sweeping reminders |
| **Apple Reminders** | Free, system integration | Generic, no Live Activity, no parking context | Parking-native, Live Activity, find-car |

### Competitive Gap Matrix
```
                    Subscription   Account    Live Activity   Street Sweep   Find Car   Apple Watch
PayByPhone          YES (bad)      YES (bad)  NO              NO             NO         NO
ParkMobile          YES (bad)      YES (bad)  NO              NO             NO         NO
SpotHero            NO             YES (bad)  NO              NO             NO         NO
SpotClock           YES (bad)      NO         YES             NO             YES        NO
overthere           NO             NO         NO              NO             YES        NO
ParkPing (Ours)     NO (one-time)  NO         YES             YES            YES        YES
```

**Conclusion**: ParkPing is the only app combining one-time purchase + no account + Live Activity + street sweeping + find-car + Apple Watch.

---

## Apple Design Guidelines Compliance

### Live Activities (HIG)
- **8-hour active limit**: Parking sessions fit naturally (typical 1-4 hour meters)
- **All 4 presentations required**: Compact, Minimal, Expanded, Lock Screen — all implemented
- **Glanceable content**: Large countdown digits, single-tap readability
- **Stale date handling**: Set staleDate to expiration time; system marks stale after expiry
- **Alert configuration**: Use alert policy for expiry notification to surface on Lock Screen
- **Dynamic Island 44pt corner radius**: Match system shape in expanded view

### WidgetKit (HIG)
- **StaticConfiguration**: Timer state fetched from SwiftData via App Group container
- **Supported families**: systemSmall (quick start), systemMedium (countdown + progress)
- **Deep link**: `parkping://start` URL scheme for one-tap start from widget
- **Refresh policy**: Timeline provider refreshes every 60 seconds when active

### App Store Review Guidelines
- **Guideline 2.1 (Performance)**: App fully functional without account or network
- **Guideline 3.1.1 (In-App Purchase)**: One-time non-consumable IAP for PRO — no subscription
- **Guideline 4.0 (Design)**: Follows HIG, uses native SF Symbols, supports Dynamic Type
- **Guideline 4.2 (Minimum Functionality)**: Free version is genuinely useful (timer + notifications + today history)
- **Guideline 5.1.1 (Privacy)**: No data collection, no tracking, no analytics — all data local
- **Guideline 5.1.2 (Data Use)**: Location used only for find-car feature, stored locally, never transmitted

### Accessibility (ADA Compliance)
- **VoiceOver**: All interactive elements labeled, countdown read aloud
- **Dynamic Type**: Scales to AX1-AX5
- **Color contrast**: WCAG AAA for countdown digits, AA for secondary text
- **Haptic feedback**: Light on tap, success on completion, warning on expiry
- **Reduce Motion**: Animations respect accessibility setting

---

## Technical Architecture

- **Language**: Swift 6.0+ (strict concurrency)
- **UI Framework**: SwiftUI (iOS 17+)
- **Data Persistence**: SwiftData (replaces Core Data)
- **Live Activity**: ActivityKit + WidgetKit
- **Notifications**: UserNotifications (local only)
- **Location**: CoreLocation (best accuracy, foreground only)
- **Maps**: MapKit (SwiftUI Map)
- **Siri**: AppIntents framework
- **Apple Watch**: WatchKit + SwiftUI (watchOS 10+)
- **In-App Purchase**: StoreKit 2 (one-time non-consumable)
- **Haptics**: UIKit feedback generators
- **Networking**: NONE (fully offline — privacy advantage)
- **Third-party deps**: NONE (pure Apple frameworks, lower review risk)

---

## Module Structure

```
ParkPing/
├── App/
│   ├── ParkPingApp.swift              # App entry, SwiftData container, onboarding
│   └── ContentView.swift              # Root tab view
├── Models/
│   ├── ParkingSession.swift           # @Model class
│   └── ParkingActivityAttributes.swift # ActivityKit attributes
├── Engine/
│   ├── TimerEngine.swift              # Core timer logic (ObservableObject)
│   ├── NotificationManager.swift      # Local notification scheduling
│   ├── LocationManager.swift          # CoreLocation wrapper
│   └── StoreManager.swift             # StoreKit 2 IAP
├── Views/
│   ├── Main/
│   │   ├── MainView.swift             # Big START button + countdown
│   │   └── MainViewModel.swift
│   ├── History/
│   │   ├── HistoryView.swift          # Session list + statistics
│   │   └── HistoryViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift         # PRO upgrade, restore, support, legal
│   │   └── SettingsViewModel.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift       # 1-page welcome
│   └── FindCar/
│       └── FindCarView.swift          # Map + navigation
├── LiveActivity/
│   ├── ParkingLiveActivity.swift      # ActivityKit widget
│   ├── LockScreenView.swift
│   └── DynamicIslandView.swift
├── Widget/
│   ├── ParkPingWidget.swift           # Home screen widget
│   └── WidgetTimelineProvider.swift
├── Intents/
│   └── StartParkingIntent.swift       # Siri shortcut
├── Watch/
│   ├── ParkPingWatchApp.swift         # Watch entry
│   └── WatchContentView.swift
└── Shared/
    ├── Haptics.swift                  # Feedback helpers
    └── Theme.swift                    # Colors, fonts, constants
```

---

## Feature Inventory (MANDATORY — Every Feature)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | One-tap start parking timer | 1. Open app → 2. Tap giant START button | Default 120 min (or preset via swipe) | Create ParkingSession, schedule notifications, start Live Activity, start timer | Countdown displayed on main view + Dynamic Island + Lock Screen | SwiftData ParkingSession row | Live Activity appears in <1s; notification scheduled; countdown decrements every 1s |
| 2 | Live Activity (Dynamic Island + Lock Screen) | Auto-starts with Feature 1 | Session start/end/duration | ActivityKit request with attributes | Compact/Minimal/Expanded/Lock Screen views | ActivityKit system-managed | All 4 presentations render correctly; updates every 60s; auto-ends on session end |
| 3 | Local notifications (5-min warning + expiry) | Auto-scheduled with Feature 1 | Warning offset = -5 min; Expiry offset = 0 | UNTimeIntervalNotificationTrigger | Two notifications fired at correct times | UNUserNotificationCenter pending queue | Warning fires 5 min before expiry; expiry fires at expiry; both marked .timeSensitive |
| 4 | Stop parking ("I'm Back") | 1. Tap "I'm Back" button | None | Set endTime, status=completed, cancel pending notifications, end Live Activity | Session saved to history | SwiftData update | Live Activity dismissed; notifications cancelled; session appears in today's history |
| 5 | Quick duration presets | 1. Swipe left on main view → 2. Tap 1h/2h/4h/8h | Duration in minutes | Update selected duration before start | Selected duration highlighted on START button | In-memory state | Preset selection updates START button label; tapping START uses selected duration |
| 6 | Save parking location | 1. Swipe right on main view (or tap pin icon) | CLLocation from CoreLocation | Store lat/long in ParkingSession | Location shown in Find Car view | ParkingSession.latitude/longitude | Location captured with kCLLocationAccuracyBest; address reverse-geocoded for display |
| 7 | Find car (map + navigation) | 1. Tap Find Car tab → 2. View map → 3. Tap directions | Saved lat/long | MapKit coordinate display | Map with pin + "Get Directions" button opens Apple Maps | Read from ParkingSession | Map shows saved location; directions button launches Apple Maps turn-by-turn |
| 8 | History view | 1. Tap History tab | None | Fetch all sessions, group by date | List grouped by Today/Yesterday/older; total stats | SwiftData query | Sessions sorted desc by startTime; grouped by day; shows duration, location, status |
| 9 | History statistics | 1. Open History view | None | Aggregate: total sessions, total time, this week | Stats header: "3h | 2 sessions" | Computed from SwiftData | Stats update when sessions added/removed |
| 10 | Street sweeping reminder | 1. Tap "Add Sweeping Reminder" in menu → 2. Select day/time → 3. Toggle repeat | Day of week, time, repeat flag | Schedule recurring UNCalendarNotificationTrigger | Recurring weekly notification | UNUserNotificationCenter + UserDefaults config | Notification fires weekly at set time; can be toggled on/off; persists across restarts |
| 11 | Apple Watch app | 1. Open Watch app → 2. View remaining time | None (synced via App Group) | Read active session from shared SwiftData | Large countdown display on Watch | Shared App Group container | Watch shows same countdown as iPhone; updates every 60s; tap to open iPhone app |
| 12 | Home screen widget | 1. Long-press home → 2. Add ParkPing widget | None | TimelineProvider reads active session | Small: START button or countdown; Medium: countdown + progress bar | App Group shared SwiftData | Widget shows live countdown when active; shows START button when idle; tap starts timer |
| 13 | Siri integration | 1. "Hey Siri, I parked" | Duration (optional, default 120) | StartParkingIntent creates session + notifications + Live Activity | Siri confirmation dialog + timer started | SwiftData + ActivityKit | Siri responds "Parking timer started for X minutes"; Live Activity appears |
| 14 | PRO upgrade (one-time IAP) | 1. Settings → 2. Tap "Upgrade to PRO" → 3. Confirm Apple Pay | Product ID com.parkping.pro | StoreKit 2 purchase flow | Unlock all PRO features | StoreKit transaction (verifiable) | Purchase verified; isPro=true; all PRO features unlocked; restore works across devices |
| 15 | Onboarding (1-page welcome) | 1. First launch only | None | Show welcome card explaining no-account/no-subscription/no-tracking | Dismiss → request notification permission | UserDefaults flag | Shown only once; notification permission requested after dismiss |
| 16 | Notification permission request | 1. After onboarding dismiss | None | UNAuthorizationOptions [.alert, .sound, .badge] | System permission dialog | System settings | Permission requested once; if denied, settings deep-link available |
| 17 | Photo recording of parking spot | 1. During active session → 2. Tap camera icon → 3. Take/save photo | UIImage from camera or photo library | Save to App's documents directory, store path in session | Photo thumbnail in history detail | File system + ParkingSession.photoPath | Photo saved with unique filename; thumbnail shown in history; full image on tap |
| 18 | Haptic feedback | Auto on key actions | None | UIImpactFeedbackGenerator / UINotificationFeedbackGenerator | Light tap on button press, success on completion, warning on expiry | None | Haptics fire at correct moments; respect system haptic settings |
| 19 | Settings view | 1. Tap Settings tab | None | Render settings list | PRO upgrade, restore, version, contact support, privacy, terms | UserDefaults + StoreKit | All links functional; version read from Bundle; PRO state reflected |
| 20 | Restore purchases | 1. Settings → 2. Tap "Restore Purchases" | None | Transaction.currentEntitlements iteration | isPro set if valid entitlement | StoreKit verified transaction | Restore works on fresh install; handles network errors gracefully |
| 21 | Free version limits | Auto-enforced | None | Check isPro before allowing >120 min or >1 active session | Upgrade prompt if limit hit | StoreKit isPro state | Free users capped at 120 min and 1 active session; PRO users unlimited |
| 22 | Expiry state handling | Auto when timer reaches 0 | None | Update session status=expired, Live Activity turns red, fire expiry notification | Red countdown, expired badge in history | SwiftData status update | Live Activity turns red at expiry; notification fires; session marked expired |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Start timer | Default duration | 120 minutes default, no duration picker shown initially | Tap START immediately starts 2h timer |
| 1.2 | Start timer | Custom duration via swipe | Swipe left reveals 1h/2h/4h/8h preset chips | Swipe left → tap preset → START uses new duration |
| 2.1 | Live Activity | Compact leading | Car.fill icon | Auto-rendered by system |
| 2.2 | Live Activity | Compact trailing | "Xm" remaining minutes | Auto-rendered, updates every 60s |
| 2.3 | Live Activity | Expanded bottom | Progress bar (blue→orange→red) | Long-press to expand |
| 2.4 | Live Activity | Lock Screen | Full banner with car icon, countdown, progress | Visible without unlock |
| 2.5 | Live Activity | Color states | Blue (normal) → Orange (≤5 min) → Red (expired) | Auto-transition based on remaining time |
| 4.1 | Stop parking | "I'm Back" button | Replaces START button when session active | Tap → confirm → session ends |
| 4.2 | Stop parking | Completion animation | Success haptic + checkmark animation | Auto-play on stop |
| 6.1 | Save location | Reverse geocoding | Convert lat/long to human-readable address | CLGeocoder async call |
| 8.1 | History | Swipe to delete | Swipe left on row reveals delete | Swipe left → tap Delete |
| 8.2 | History | Tap for detail | Tap row opens detail with map + photo | Tap → detail sheet |
| 10.1 | Street sweeping | Day picker | Multi-select days of week | Toggle chips for Mon-Sun |
| 10.2 | Street sweeping | Time picker | Time of day for reminder | UIDatePicker in .time mode |
| 14.1 | PRO upgrade | Paywall sheet | Feature list + price + purchase button | Sheet presented on upgrade tap |
| 14.2 | PRO upgrade | Limited promo | First 30 days: $1.99 (50% off) | Price loaded from StoreKit |
| 17.1 | Photo | Camera or library | Action sheet to choose source | Action sheet → camera or photo library |
| 19.1 | Settings | Version display | Read MARKETING_VERSION from Bundle | Auto-updated when Xcode version bumped |
| 19.2 | Settings | Contact support | Mail composer or feedback URL | Tap → mailto: or FEEDBACK_BACKEND_URL |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Start → Live Activity | Feature 1 | Feature 2 | Session start/end/duration | Session created |
| Start → Notifications | Feature 1 | Feature 3 | Session expiration time | Session created |
| Start → Widget update | Feature 1 | Feature 12 | Session active state | Session created or ended |
| Start → Watch sync | Feature 1 | Feature 11 | Active session via App Group | Session created or ended |
| Stop → History | Feature 4 | Feature 8 | Completed session | Session status set to completed |
| Location save → Find Car | Feature 6 | Feature 7 | Lat/long coordinates | Location captured |
| Expiry → Live Activity color | Feature 22 | Feature 2 | isExpired flag | Timer reaches 0 |
| PRO purchase → Limits lifted | Feature 14 | Feature 21 | isPro boolean | Verified transaction |

---

## Data Flow Diagrams (MANDATORY)

### Feature 1: Start Parking Timer
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap START button (or Siri intent or widget tap)     │
│       │                                                   │
│  ViewModel Processing (MainViewModel)                     │
│  └── Validate no active session exists                   │
│  └── Check isPro → if free & duration>120, prompt upgrade│
│  └── Create ParkingSession(durationMinutes:)              │
│       │                                                   │
│  Model/Persistence (SwiftData)                            │
│  └── modelContext.insert(session)                         │
│  └── try? modelContext.save()                             │
│       │                                                   │
│  Service Calls (parallel)                                 │
│  ├── NotificationManager.scheduleWarning(session)        │
│  ├── NotificationManager.scheduleExpiry(session)         │
│  ├── TimerEngine.startLiveActivity(session)              │
│  └── TimerEngine.startTimer() // 1s tick                  │
│       │                                                   │
│  Display Output                                           │
│  ├── MainView: countdown label + "I'm Back" button       │
│  ├── Dynamic Island: compact car + Xm                    │
│  ├── Lock Screen: full banner with countdown             │
│  └── Widget: live countdown (via timeline refresh)       │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── App Group shared container updated for Watch/Widget │
└───────────────────────────────────────────────────────────┘
```

### Feature 4: Stop Parking ("I'm Back")
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "I'm Back" button                               │
│       │                                                   │
│  ViewModel Processing (MainViewModel)                     │
│  └── session.endTime = Date()                            │
│  └── session.status = .completed                         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── try? modelContext.save()                             │
│       │                                                   │
│  Service Calls                                            │
│  ├── UNUserNotificationCenter.removePendingNotification  │
│  │   (identifiers: ["warning-\(id)", "expiry-\(id)"])    │
│  ├── activity.end(dismissalPolicy: .immediate)           │
│  └── timer.invalidate()                                   │
│       │                                                   │
│  Display Output                                           │
│  ├── MainView: success haptic + checkmark animation      │
│  ├── Dynamic Island: dismissed                            │
│  ├── Lock Screen: dismissed                               │
│  └── Widget: reverts to START button                     │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Session now appears in HistoryView (Feature 8)      │
└───────────────────────────────────────────────────────────┘
```

### Feature 6+7: Save Location & Find Car
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Swipe right on main view OR tap pin icon            │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── LocationManager.requestLocation()                   │
│  └── On location: session.latitude/longitude = coord     │
│  └── CLGeocoder.reverseGeocodeLocation → address         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── session.locationName = address                      │
│  └── try? modelContext.save()                             │
│       │                                                   │
│  Display Output (Find Car View)                           │
│  └── Map(position: .coordinate(lat, long))               │
│  └── Annotation for car location                         │
│  └── "Get Directions" button → opens maps://?daddr=      │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── History detail shows map snippet for located session│
└───────────────────────────────────────────────────────────┘
```

### Feature 14: PRO Upgrade (StoreKit 2)
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Upgrade to PRO" in Settings                    │
│       │                                                   │
│  ViewModel Processing (StoreManager)                      │
│  └── Product.products(for: ["com.parkping.pro"])         │
│  └── product.purchase() → VerificationResult             │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Transaction verified → isPro = true                 │
│  └── await transaction.finish()                          │
│       │                                                   │
│  Display Output                                           │
│  ├── Paywall dismisses with success haptic               │
│  └── Settings shows "PRO ✓" badge                        │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Feature 21: Duration cap removed (free→unlimited)   │
│  └── Feature 21: Active session cap removed              │
└───────────────────────────────────────────────────────────┘
```

---

## Implementation Flow

### Phase 1: MVP (Core Timer) — Week 1-2
1. Set up SwiftData model `ParkingSession`
2. Implement `TimerEngine` with start/stop/tick logic
3. Build `MainView` with giant START button and countdown display
4. Implement `NotificationManager` (5-min warning + expiry)
5. Build `HistoryView` with grouped list and statistics
6. Request notification permission on onboarding
7. Unit test core timer logic

### Phase 2: Differentiation (Live Activity + Watch) — Week 3-4
1. Define `ParkingActivityAttributes` and `ContentState`
2. Implement Lock Screen presentation view
3. Implement Dynamic Island compact/minimal/expanded presentations
4. Wire `TimerEngine` to update Live Activity every 60s
5. Build home screen widget (`StaticConfiguration`)
6. Build Apple Watch app reading shared App Group SwiftData
7. Add haptic feedback and button animations

### Phase 3: Value-Add Features — Week 5-6
1. Implement `LocationManager` (CoreLocation wrapper)
2. Build `FindCarView` with MapKit
3. Implement `StartParkingIntent` (AppIntents + Siri phrases)
4. Build street sweeping reminder (recurring UNCalendarNotificationTrigger)
5. Implement `StoreManager` (StoreKit 2 one-time IAP)
6. Build paywall sheet and free-version limits
7. Add photo recording feature (camera + photo library)

### Phase 4: Polish & Ship — Week 7
1. Polish animations (button press, expiry color transition, completion celebration)
2. Verify VoiceOver labels and Dynamic Type scaling
3. Test dark mode and StandBy
4. Performance optimization (timer efficiency, SwiftData queries)
5. TestFlight beta test
6. App Store metadata (screenshots, description, keywords)
7. Submit for review

---

## UI/UX Design Specifications

### Color Scheme
```swift
// Primary — trust, professional
parkPrimary    = #007AFF (Apple Blue)  // START button, normal countdown
// Warning — 5-minute pre-expiry
parkWarning    = #FF9E0A (Orange)      // Countdown ≤5 min
// Danger — expired
parkDanger     = #FF3B30 (Red)         // Expired state, Live Activity red
// Success — completed
parkSuccess    = #34C759 (Green)       // Completion checkmark
// Backgrounds
parkBgLight    = .systemBackground
parkBgDark     = .systemGroupedBackground
```

### Typography
- **Countdown digits**: SF Pro Rounded, .system(size: 72, weight: .bold), monospacedDigit
- **Headlines**: SF Pro, .largeTitle
- **Body**: SF Pro, .body
- **Captions**: SF Pro, .caption

### Layout
- **Standard corner radius**: 16pt
- **Grid spacing**: 8pt base unit
- **START button**: Full width minus 32pt margins, height 80pt, corner radius 40pt (capsule)
- **Countdown**: Centered, 72pt font, padding 24pt

### 2026 Design Trends Applied
1. **New Minimalism**: Single-purpose main screen, generous white space, no clutter
2. **Dynamic Typography**: Countdown digits animate from 0 to target on start
3. **Soft Light/Shadow**: Subtle shadows on START button, no harsh gradients
4. **Glassmorphism**: Frosted background on countdown card when active
5. **Dark Mode**: Full support, colors adjust via system assets
6. **Bottom Navigation**: TabView with Timer / History / Settings (3 tabs max)

### Key Interactions
- **Tap START**: Immediate response (<16ms) + light haptic + scale 0.95 → 1.0 spring
- **Countdown tick**: Digits do not animate per-tick (would be distracting); only color transitions
- **Expiry color transition**: Smooth 0.5s animation blue → orange → red
- **Completion**: Success haptic + checkmark scale-in + confetti particles
- **Swipe gestures**: Reveal preset chips (left) or location save (right) with spring animation

### Iconography
- **App icon**: Two-P symmetrical logo (ParkPing), blue gradient background
- **SF Symbols**: `car.fill` (parking), `clock` (timer), `mappin.circle` (location), `exclamationmark.triangle.fill` (warning), `checkmark.circle.fill` (success)

---

## Code Generation Rules

1. **One feature per module**: High cohesion, low coupling — each view has its own ViewModel
2. **MVVM architecture**: View → ViewModel → Engine/Service → SwiftData
3. **Swift 6 strict concurrency**: All async operations use async/await; @MainActor for UI
4. **SwiftData first**: No Core Data, no UserDefaults for business data (only for onboarding flag + street sweeping config)
5. **Error handling**: All throwing calls wrapped in do/catch with user-friendly messages
6. **No third-party deps**: Pure Apple frameworks (lower review risk, no supply chain)
7. **Localization ready**: All user-facing strings via LocalizedStringResource (English primary)
8. **No comments unless asked**: Self-documenting code via clear naming
9. **Version dynamic**: Read from `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` — never hardcode
10. **Semantic naming**: `ParkingSession`, `TimerEngine`, `MainView` — not `Model1`, `Manager`, `VC1`

---

## Build & Deployment Checklist

- [ ] Xcode project target: iOS 17.0+
- [ ] Bundle ID: com.zzoutuo.ParkPing
- [ ] Capabilities: Push Notifications (for time-sensitive local), Live Activity, App Groups (for Watch/Widget sharing), Siri
- [ ] Info.plist: NSLocationWhenInUseUsageDescription, NSCameraUsageDescription, NSPhotoLibraryUsageDescription, Siri usage description
- [ ] App Icon: 1024x1024 + all required sizes generated
- [ ] StoreKit configuration: com.parkping.pro (non-consumable, $3.99)
- [ ] StoreKit configuration file for testing in simulator
- [ ] URL scheme: parkping:// (for widget deep link)
- [ ] App Group: group.com.zzoutuo.ParkPing (shared SwiftData container)
- [ ] Watch app target: watchOS 10+
- [ ] Widget extension target: iOS 17+
- [ ] Live Activity enabled in Info.plist: NSSupportsLiveActivities = YES
- [ ] Test on iPhone 16 (Dynamic Island), iPhone SE (no Dynamic Island), iPad
- [ ] Test free version limits enforce correctly
- [ ] Test StoreKit purchase flow in sandbox
- [ ] Test Siri intent phrases
- [ ] Verify all Live Activity presentations render
- [ ] VoiceOver navigation tested
- [ ] Dark mode tested
- [ ] Submit to App Store with review notes explaining one-time purchase model

---

## App Store Compliance Notes

- **No subscription**: This app uses one-time non-consumable IAP only. No auto-renewing subscription. No subscription disclosure required in app description.
- **No account**: App is fully functional without any user account. No sign-in flow.
- **No data collection**: App collects no personal data. Privacy nutrition label: "Data Not Collected".
- **Free version genuinely useful**: Timer (up to 2h), notifications, today history — meets App Store minimum functionality (Guideline 4.2).
- **Location usage**: Used only for find-car feature, foreground only, stored locally, never transmitted. Description: "ParkPing uses your location only when you tap 'Save Location' to remember where you parked. Your location is stored only on your device and never sent to any server."
- **Notification usage**: Local notifications only, for parking reminders. Marked .timeSensitive for expiry alert.
- **Camera/Photo usage**: Optional photo of parking spot. Stored locally. Auto-delete after 30 days optional.
