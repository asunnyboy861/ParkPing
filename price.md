# Pricing Configuration

## Monetization Model: Freemium with One-Time IAP

ParkPing is free to download with a genuinely useful free tier (1 active timer, 2-hour cap, local notifications, today's history). A one-time non-consumable in-app purchase unlocks all PRO features permanently. No subscription, no recurring billing, no account required.

## In-App Purchase Product

### ParkPing PRO (One-Time Unlock)

- **Reference Name**: ParkPing PRO
- **Product ID**: `com.zzoutuo.ParkPing.pro`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $3.99 USD (one-time)
- **Display Name**: `ParkPing PRO` (12 chars, ≤35 ✅)
- **Description**: `Unlimited timers, Live Activity, Widget, Watch & more.` (54 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required (StoreKit 2 `Transaction.currentEntitlements`)
- **Family Sharing**: ✅ Supported
- **Introductory Price**: $1.99 (50% off for first 30 days after release, configured in App Store Connect)

## Free Tier (Default)

- **Price**: Free
- **Features**:
  - 1 active parking timer
  - Timer duration cap: 2 hours
  - Local notifications (5-minute warning + expiry alert)
  - Today's parking history
  - Haptic feedback
  - Dark mode support
- **Conversion hooks**:
  - Attempting to set duration >2 hours → PRO upgrade prompt
  - Attempting to start 2nd timer while 1 is active → PRO upgrade prompt
  - Tapping Live Activity / Widget / Watch features → PRO upgrade prompt
  - "Upgrade to PRO" button in Settings tab

## Pro Features Unlocked

⚠️ **CRITICAL**: Every feature listed below is confirmed in `capabilities.md` from PHASE 2 and will be implemented in PHASE 4+5.

| Feature | Free | PRO |
|---------|:----:|:---:|
| Active parking timers | 1 | Unlimited |
| Timer duration | Max 2 hours | Unlimited |
| Local notifications (5-min warning + expiry) | ✅ | ✅ |
| Today's history | ✅ | ✅ |
| Live Activity + Dynamic Island | ❌ | ✅ |
| Home screen Widget | ❌ | ✅ |
| Apple Watch app | ❌ | ✅ |
| Full history (all sessions) + statistics | ❌ | ✅ |
| Parking location save + Find car (map) | ❌ | ✅ |
| Siri voice integration ("Hey Siri, I parked") | ❌ | ✅ |
| Street sweeping reminders | ❌ | ✅ |
| Photo recording of parking spot | ❌ | ✅ |
| Ads | None (always ad-free) | None |

## Policy Pages Required

- Support Page: ✅ (must include restore purchases instructions)
- Privacy Policy: ✅ (data collection: none — "Data Not Collected")
- Terms of Use (EULA): ✅ (recommended for any paid IAP app — includes IAP terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist

- [x] One-time non-consumable IAP (no auto-renewal — no subscription disclosure needed)
- [x] Pricing clearly stated in PaywallView ($3.99 one-time)
- [x] Restore purchases functionality implemented (StoreKit 2)
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters (verified: 54 chars)
- [x] All IAP display names ≤ 35 characters (verified: 12 chars)
- [x] Free tier is genuinely useful (meets Guideline 4.2 minimum functionality)
- [x] Family Sharing supported
- [x] No dark patterns in Paywall (clear pricing, easy dismiss)
- [x] Privacy Policy linked from Paywall (Guideline 5.1.2)
- [x] Terms of Use linked from Paywall (best practice for IAP)
