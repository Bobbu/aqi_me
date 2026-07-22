# AQI Me — App Store Listing (iOS, draft)

Copy-paste-ready content for App Store Connect. Character limits noted. Universal
app (iPhone + iPad). Draft for review.

---

## App name (max 30)
```
AQI Me
```

## Subtitle (max 30)
```
Air quality at a glance
```
*(23 chars. Alt: `Live air quality, kept private` (29).)*

## Promotional text (max 170, editable without review)
```
Live Air Quality Index for the places you care about — home, family, your next trip.
Private by design: no account, no ads, no tracking.
```

## Keywords (max 100, comma-separated, no spaces)
```
air quality,AQI,pollution,PM2.5,ozone,smoke,smog,air pollution,weather,pollutant,health,index
```
*(~92 chars — trim if App Store Connect flags it. Don't repeat words from the app name/subtitle; Apple already indexes those.)*

## Description (max 4000)
```
AQI Me shows the current Air Quality Index (AQI) for the places you care about —
home, family across the country, your next trip — all on one clean screen.

Add up to 20 locations by name (“Denver, CO”, “London, UK”) or GPS coordinates, and
see each one’s live reading color-coded on the US EPA scale, from Good (green) to
Hazardous (maroon). A single glance tells you whether the air is clear or whether
somewhere needs your attention.

WHAT YOU GET
• Current AQI for up to 20 locations, refreshed hourly
• An at-a-glance scale bar that plots every location on the AQI spectrum, so you can
  see how each place compares — and how close any is to the next level
• Tap a dot to jump straight to that location’s card
• Each card shows the AQI value and category, the dominant pollutant (PM2.5, O₃, and
  more), the temperature, and the local time of the reading
• Grid or list view, with drag-and-drop reordering
• A built-in guide to the AQI scale and what each pollutant means
• Light and dark themes
• Universal — designed for both iPhone and iPad

PRIVATE BY DESIGN
• No account. No sign-up. Just open it and go.
• No ads. No trackers. No analytics.
• Your list of locations is stored only on your device — never uploaded to us.
• Air-quality data comes from the free, open Open-Meteo service.

AQI Me is a calm instrument for a simple question: how’s the air, right now, in the
places that matter to me?

Also available on the web at aqi-me.anystupididea.com.
```

## Metadata
- **Primary category:** Weather
- **Secondary category:** Health & Fitness (optional)
- **Age rating:** 4+ (no objectionable content — answer all questionnaire items "None/No")
- **Copyright:** © 2026 Any Stupid Idea
- **Support URL:** https://anystupididea.com  *(or a dedicated support/contact page)*
- **Marketing URL (optional):** https://aqi-me.anystupididea.com
- **Privacy Policy URL:** <your existing Privacy page URL> ✅

## Export compliance
- `ITSAppUsesNonExemptEncryption = false` is set in `Info.plist` (we use only standard
  HTTPS / no custom cryptography), so uploads won't prompt for the encryption question.

---

## App Privacy ("nutrition label") — review carefully
Same substance as Play's data-safety form. The app has **no account, no analytics, no
ads, no advertising identifier, no CoreLocation** (it never requests device-location
permission), and stores the location list **only on device**. The one nuance:

**Location.** You type the place yourself; the app then sends the **queried coordinates**
to the Open-Meteo API to fetch a reading. That's data leaving the device to a third
party. The conservative, honest declaration:

- **Data Types → Location → Precise Location** (lat/lon is precise)
  - **Used for:** App Functionality
  - **Linked to the user's identity?** No (there's no account/identifier)
  - **Used for tracking?** No
- **All other categories** (Contact Info, Identifiers, Usage Data, Diagnostics, etc.):
  **Not Collected**

> Alternative view: because there's no location *permission* and the value is a place
> the user searched (not their device's location), some would select **"Data Not
> Collected."** Sending coordinates to a third-party API is why the safe answer is to
> disclose Location under *App Functionality, not linked, not tracking*. Skim Apple's
> App Privacy definitions before you finalize.

---

## Screenshots (generating)
App Store Connect requires the largest device sizes; smaller ones are optional.
- **iPhone 6.7"** — 1290×2796 (from the iPhone 16 Pro Max simulator)
- **iPad 13"** — 2064×2752 (from the iPad Pro 13" simulator)

Same three compositions as the Play set (grid hero, dark list, AQI-scale help sheet),
captured at these device sizes.

## Build / upload
- `flutter build ipa --release` → `build/ios/ipa/*.ipa`
- Upload via **Transporter** (Mac App Store) or Xcode Organizer, or `xcrun altool` /
  Fastlane `deliver`. First upload may require creating the App Store Connect app record
  (bundle id `com.anystupididea.aqime`) and accepting any pending Apple agreements.

## Release notes (first version, max 4000)
```
First release of AQI Me — live air quality for up to 20 places, private by design.
No account, no ads. Universal for iPhone and iPad.
```
