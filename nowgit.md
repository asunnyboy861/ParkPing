# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | ParkPing |
| **Git URL** | git@github.com:asunnyboy861/ParkPing.git |
| **Repo URL** | https://github.com/asunnyboy861/ParkPing |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/ParkPing/ | ✅ Active |
| Support | https://asunnyboy861.github.io/ParkPing/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/ParkPing/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/ParkPing/terms.html | ✅ Active |

## Repository Structure

```
ParkPing/
├── ParkPing/                      # iOS App Source Code
│   ├── ParkPing.xcodeproj/        # Xcode Project
│   └── ParkPing/                  # Swift Source Files
│       ├── Engine/                # TimerEngine, StoreManager, LocationManager, NotificationManager
│       ├── Models/                # ParkingSession, ParkingActivityAttributes
│       ├── Shared/                # Theme, Haptics
│       ├── Views/                 # Main, History, Settings, Paywall, Onboarding, FindCar, Support
│       ├── Intents/               # StartParkingIntent (Siri)
│       ├── LiveActivity/          # ParkingLiveActivityView (Dynamic Island + Lock Screen)
│       └── Widget/                # ParkPingWidget (Home Screen Widget)
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md                          # English development guide
├── capabilities.md                # Xcode capabilities configuration
├── icon.md                        # App icon generation documentation
├── price.md                       # Pricing configuration
├── nowgit.md                      # Git repository documentation
├── improvement_plan_1.md          # Code review improvement plan
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
└── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore — confidential competitor analysis)
```
