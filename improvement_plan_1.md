# Improvement Plan #1 — ParkPing

## Self-Review Findings

### Issues Found

| # | Severity | File | Issue | Fix |
|---|----------|------|-------|-----|
| 1 | Medium | SettingsView.swift | `showStreetSweeping` state declared but never triggered. `.sheet(isPresented: $showStreetSweeping)` is dead code — StreetSweepingView is presented via NavigationLink. | Remove unused `showStreetSweeping` state and the dead `.sheet` modifier. |
| 2 | Low | OnboardingView.swift | `@Environment(\.dismiss)` declared but never used. | Remove unused `dismiss` environment variable. |
| 3 | Medium | HistoryView.swift | `groupedSessions` sorts date groups using string comparison (`$0.key > $1.key`), which doesn't sort formatted date strings correctly. | Sort by the first session's `startTime` instead of string comparison. |
| 4 | Low | ParkPingApp.swift | `_ = StoreManager.shared` is a side-effect-only expression that's unclear. | Add a clarifying approach — call a dedicated initialization method or use `_ =` with explicit intent. |
| 5 | Medium | Widget/ParkPingWidget.swift | Widget and Live Activity code is in the main app target. Needs Widget Extension target to function. | Document in capabilities.md that Widget Extension must be created manually. Code is ready to move. |
| 6 | Low | TimerEngine.swift | `Combine` import is unused (no Combine patterns used). | Remove unused import. |

### Compliance Verification

| Rule | Status | Notes |
|------|--------|-------|
| COMPLIANCE-IAP | ✅ Pass | StoreManager uses `Transaction.currentEntitlement(for:)`, `@Published isPro`, views use `@StateObject` |
| COMPLIANCE-PAYWALL | ✅ Pass | PaywallView includes Privacy Policy + Terms of Use links below purchase button |
| CRITICAL RULE #7 (no comments) | ✅ Pass | No comments in generated Swift files |
| CRITICAL RULE #11 (English UI) | ✅ Pass | All UI text is in English |
| CRITICAL RULE #14 (inherit over hardcode) | ✅ Pass | App version read from `Bundle.main.infoDictionary` |

## Fixes Applied

1. Removed unused `showStreetSweeping` state and dead `.sheet` modifier from SettingsView
2. Removed unused `@Environment(\.dismiss)` from OnboardingView
3. Fixed `groupedSessions` date sorting in HistoryView to sort by actual session date
4. Removed unused `Combine` import from TimerEngine
5. Widget/Live Activity code documented as requiring manual Widget Extension target creation

## Build Verification

- Build status: ✅ Succeeded (3.6s)
- App launches: ✅ Onboarding view displays correctly
- Bundle ID: com.zzoutuo.ParkPing
- Target: iPhone 16 (iOS Simulator)
