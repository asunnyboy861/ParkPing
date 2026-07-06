# Capabilities Configuration

## Analysis
Based on operation guide (`TR-20260706-停车计时提醒-操作指南.md`) and `us.md` analysis, the following capabilities were detected:

| Keyword Found | Capability Detected |
|---------------|---------------------|
| "通知" / "notification" / "提醒" | Push Notifications (local) |
| "Live Activity" / "Dynamic Island" | Live Activity (ActivityKit) |
| "定位" / "location" / "地图" | Location Services (CoreLocation) |
| "相机" / "拍照" / "照片" | Camera + Photo Library |
| "语音" / "Siri" | Siri (AppIntents) |
| "手表" / "Apple Watch" | Apple Watch (watchOS target) |
| "购买" / "premium" / "PRO" | In-App Purchase (StoreKit 2) |
| Widget / "小组件" | Widget Extension (WidgetKit) |
| App Group (Watch/Widget sharing) | App Groups |

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Live Activity (NSSupportsLiveActivities) | ✅ Configured | INFOPLIST_KEY_NSSupportsLiveActivities = YES in project.pbxproj |
| Location When In Use | ✅ Configured | INFOPLIST_KEY_NSLocationWhenInUseUsageDescription in project.pbxproj |
| Camera | ✅ Configured | INFOPLIST_KEY_NSCameraUsageDescription in project.pbxproj |
| Photo Library | ✅ Configured | INFOPLIST_KEY_NSPhotoLibraryUsageDescription in project.pbxproj |
| Siri | ✅ Configured | INFOPLIST_KEY_NSSiriUsageDescription in project.pbxproj |
| App Groups | ✅ Configured | ParkPing.entitlements (group.com.zzoutuo.ParkPing) |
| Code Signing Entitlements | ✅ Configured | CODE_SIGN_ENTITLEMENTS = ParkPing/ParkPing.entitlements |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Push Notifications capability (Xcode Signing & Capabilities) | ⏳ Pending | Open Xcode → ParkPing target → Signing & Capabilities → + Capability → Push Notifications. Required for time-sensitive local notifications to surface prominently. App works without it (notifications still fire, just not .timeSensitive priority). |
| In-App Purchase capability (Xcode Signing & Capabilities) | ⏳ Pending | Open Xcode → ParkPing target → Signing & Capabilities → + Capability → In-App Purchase. Then create IAP product `com.parkping.pro` (Non-Consumable, $3.99) in App Store Connect. App works in free mode without this; PRO upgrade requires it. |
| Apple Watch target | ⏳ Pending | Open Xcode → File → New → Target → watchOS App → configure Watch App. The Watch app code will be generated in PHASE 4+5 but the target must be created manually. App works fully on iPhone without Watch target. |
| Widget Extension target | ⏳ Pending | Open Xcode → File → New → Target → Widget Extension. The Widget code will be generated in PHASE 4+5 but the target must be created manually. App works fully without Widget (just no home screen widget). |

## No Configuration Needed
- iCloud: Not needed (all data local via SwiftData)
- HealthKit: Not needed (no health features)
- Sign in with Apple: Not needed (no accounts)
- Background Modes: Not needed (Live Activity is system-managed, not background fetch)
- CloudKit: Not needed (privacy-first, no server)

## Graceful Degradation
The app is designed to work with **zero manual configuration**:
- **Without Push Notifications capability**: Local notifications still fire (just without .timeSensitive priority)
- **Without IAP capability**: App works in free mode (timer up to 2h, 1 active session)
- **Without Watch target**: iPhone app fully functional
- **Without Widget target**: iPhone app fully functional
- **Without App Groups**: App works (Watch/Widget sharing disabled until configured)

Manual configuration only **enhances** the experience — it does not block core functionality.

## Verification
- Build succeeded after configuration: ✅ PASSED (iPhone 16 simulator, 6.5s)
- All entitlements correct: ✅ (ParkPing.entitlements created with App Groups)
- Info.plist usage descriptions: ✅ (all 4 added via INFOPLIST_KEY_ settings)
- Live Activity support flag: ✅ (NSSupportsLiveActivities = YES)
