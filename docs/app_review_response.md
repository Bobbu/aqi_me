# App Store — Review Response (Guideline 2.1, Information Needed)

**Submission ID:** 24cdeb69-3edf-48e2-82c5-ff3d1556de8f
**Build:** 1.0.0 (1) · **App Apple ID:** 6793547564 · **Bundle:** `com.anystupididea.aqime`
**Rejection:** Guideline 2.1 — Information Needed (New App Submission), received 2026-07-22.

## What this rejection actually is
Apple's standard "we need more context" template, sent when the **App Review
Information → Notes** field is empty. It is **not** a bug, crash, design, or
metadata rejection — the bulleted list (login / purchases / UGC / location
prompts) is a generic checklist and each item is conditional. For AQI Me most
items are "not applicable." The fix: fill in the Notes, attach a short screen
recording, and reply in the Resolution Center, then resubmit the same build.

## Do this
1. Paste the **reply text below** into **Resolution Center → Reply to App Review**.
2. Paste the same text into **App Store Connect → App Review Information → Notes**
   (so it carries to every future submission).
3. Attach the **screen recording** (see "Screen recording" section) to the reply —
   or, if the attachment fails, link it (see "What was actually submitted" below).
4. Resubmit build 1.0.0 (1) — no code change or new build required.

## What was actually submitted (2026-07-23)
- The recording was captured on the **iPad Pro 13" (M4)** and rotation-corrected
  (see "Screen recording" notes).
- **Attaching the MP4 to the Resolution Center reply kept failing** ("submit later"),
  so it was uploaded as an **unlisted YouTube video** and delivered as a link in the
  reply. The exact message added to the reply:
  > I tried repeatedly to attach an MP4 screen recording made on my iPad, but the
  > "reply" kept failing and asked that I submit later. I uploaded the screen
  > recording as an unlisted video on YouTube -- you can view it here:
  >
  > https://youtu.be/lF10XMdR-54
- **Still to do:** the reply text + this YouTube link went into the **Resolution
  Center reply only**, not the version's **App Review Information → Notes** field.
  Add both to Notes so the next build's reviewer sees them automatically.
- **Takeaway for future submissions:** the App Store Connect reply uploader is
  flaky with video; an **unlisted YouTube (or Vimeo) link is an accepted fallback**.
  Keep the link **Unlisted or Public** (never Private) and verify it plays while
  logged out.

---

## Reply text (paste into Resolution Center + Notes)

> Thank you for the review. AQI Me is a simple, free air-quality viewer with **no
> account, no login, no in-app purchases or subscriptions, no user-generated
> content, no ads or tracking, and no requests for location or any other sensitive
> device permission.** Several items below are therefore not applicable; we've
> answered all seven for completeness.
>
> **1. Screen recording.** A recording captured on a physical iPad Pro 13" (M4) is
> provided (attached, or linked if the attachment fails — see the YouTube link in the
> reply). It launches the app and walks through the core flow: the two example locations
> that preload on first launch, adding a location by name and by GPS coordinates,
> viewing each location's color-coded AQI card, tapping a dot on the AQI scale bar
> to jump to its card, switching grid/list view, and opening the built-in AQI help
> sheet. The app never presents an account, purchase, or permission prompt — there
> is nothing to sign into and no sensitive-data access to grant.
>
> **2. Devices/OS tested.** iPhone 13 Pro Max running iOS 26.5.2 (physical device);
> iPad Pro 13-inch (M4) running iPadOS 26.5.2; plus the iPhone and iPad simulators
> in Xcode. The app is universal (iPhone + iPad).
>
> **3. Purpose & audience.** AQI Me shows the current Air Quality Index (US EPA
> scale) for up to 20 places the user chooses — home, family in other cities, an
> upcoming trip — all on one screen, color-coded from Good (green) to Hazardous
> (maroon). It solves the problem of checking air quality for several places at
> once without an account or ads. Audience: anyone who wants a quick, private,
> at-a-glance read on air quality — commuters, travelers, parents, people with
> asthma or other respiratory sensitivity. Rated 4+.
>
> **4. Setup & access to main features.** No setup, login, credentials, or sample
> files are required. On first launch the app preloads two example locations
> (Washington, D.C. and Lake Barrington, IL). Tap the "+" control to add a location
> by name ("Denver, CO", "London, UK") or by coordinates ("39.74, -104.99"); the
> app fetches and displays that location's current AQI. Tap a dot on the scale bar
> to jump to a card; use the view toggle for grid/list; open the help ("?") sheet
> for an explanation of the AQI scale and pollutant codes. That is the full app.
>
> **5. External services.** One: **Open-Meteo** (https://open-meteo.com) — a free,
> key-less public API — supplies air-quality readings, weather, and place-name
> geocoding. There are no authentication services, payment processors, ad networks,
> analytics SDKs, or AI services. Fonts are bundled in the app, so Open-Meteo is the
> only outbound network destination.
>
> **6. Regional differences.** None. The app functions consistently in all regions;
> Open-Meteo provides global coverage and the app always presents readings on the
> US EPA AQI scale. There is no region-locked or region-variant content.
>
> **7. Regulated industry / protected third-party material.** None. The app is not
> in a regulated industry and uses no protected or licensed third-party material.
> Air-quality data comes from Open-Meteo's open data; the US EPA AQI is a public
> standard. No special authorization is required.
>
> A privacy note for the reviewer: the only data that leaves the device is the
> coordinates of a place the user chose to look up, sent to Open-Meteo to fetch a
> reading. The user's list of locations is stored only on the device and is never
> uploaded to us. There is no account and no device identifier.

---

## Screen recording (item #1 — the one real deliverable)
Apple wants it captured on a **physical device** running the current OS, starting
from launch. Keep it ~30–60 seconds. Two easy paths:

**A. On-device (simplest):**
1. On the iPhone: Settings → Control Center → add **Screen Recording**.
2. Open Control Center, tap the record button, wait for the 3-2-1, then launch
   AQI Me from the Home Screen (start the recording *before* launch so it shows the
   cold start).
3. Walk the flow: example locations → tap "+" → add "Denver, CO" → add a coordinate
   like "34.05, -118.24" → view the cards → tap a scale-bar dot → toggle grid/list
   → open the "?" help sheet.
4. Stop from Control Center. The clip lands in Photos; AirDrop it to the Mac and
   attach it in the Resolution Center reply.

**B. Wired via QuickTime (crisper, easy to trim):** plug the iPhone into the Mac →
QuickTime Player → File → New Movie Recording → click the ▾ next to record and pick
the iPhone as the camera/source → record the same flow → File → Save.

Show **no** permission or login prompts — because there are none. That visually
reinforces the "no sensitive-data access" answer.

Capture the recording on the **iPhone 13 Pro Max** (physical device) — that's the
device model cited in item 2, and Apple wants the recording from real hardware.
