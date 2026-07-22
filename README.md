# AQI Me

A simple, beautiful app to track **current Air Quality Index (AQI)** for up to **20
locations** at once — added by city/state/country or GPS coordinates. No account, no login.
One Flutter codebase ships to the **web** (nothing to install — just visit the site) and to
**Android and iOS** as native apps.

**Live (web):** https://aqi-me.anystupididea.com

## What it does

- Track up to 20 places; see current AQI (≤ 1 hour old), color-coded on the US EPA scale.
- Add locations by name (*"Denver, CO"*, *"Chicago, IL"*, *"London, UK"*) or coordinates
  (*`39.74, -104.99`*), with a disambiguation picker when a name is ambiguous. Missing the
  comma is fine too — *"Greensboro GA"* resolves via a region fallback.
- New visitors start with two example locations (Washington D.C. and Lake Barrington, IL).
- Each card shows AQI + category, the dominant pollutant, temperature, and the reading
  time in the location's **named timezone** (e.g. *as of 2:00 AM EDT*).
- An **AQI scale bar** plots every location as a dot on a green→maroon gradient, so a
  glance shows where each place sits on the scale and relative to the others; tap a dot to
  jump to its card. Refreshes hourly.
- **Grid or list view**, and **drag-and-drop reordering** — both persisted per device.
- A built-in **help sheet** explains the AQI scale and the pollutant codes (PM2.5, O₃, …),
  plus a link to the how-to video.
- **Persisted light/dark theme**. Your list is saved locally, per device — nothing is
  sent to us.

## How it's built

- **Flutter** — one codebase runs on the **web, Android, and iOS**. `lib/` is 100% portable
  Dart (no web-only imports), so the same UI and logic run everywhere; fonts are bundled, so
  the only outbound calls are to Open-Meteo.
- **[Open-Meteo](https://open-meteo.com/)** — free, key-less APIs for air quality,
  weather, and geocoding. No secrets in the app.
- **AWS CDK (TypeScript)** — web hosting: private S3 + CloudFront (OAC) + Route53 + ACM, all
  in `infra/`. `cdk deploy` builds everything from scorched earth; `cdk destroy` tears it
  down. No console, no secrets.
- **Mobile** — Android release signing via an upload key (Play App Signing); beta APKs go
  out through **Firebase App Distribution** (`./distribute-android.sh`); the Google Play and
  Apple App Stores are the release targets. See the technical design doc.
- **CI/CD** — every push to `main` runs analyze + tests + build and auto-deploys the **web**
  app via GitHub Actions using OIDC (no stored AWS keys). See [`.github/workflows/deploy.yml`].

## Deploy

```bash
# Web (one-click, local): build Flutter web + cdk deploy
./deploy.sh

# Android beta: build a signed release APK + push to Firebase App Distribution
./distribute-android.sh "What's new"
```

Web also auto-deploys on every push to `main` (CI/CD). See [infra/README.md](./infra/README.md).
Mobile store submission is a manual, per-store step (see the technical design doc).

## Docs

- [Product Requirements (PRD)](./docs/PRD.md)
- [Technical Design](./docs/TECH_DESIGN.md)

## Status

- **Web:** shipped and live at https://aqi-me.anystupididea.com.
- **iOS:** build 1.0.0 (1) **submitted to the App Store — in review**. Support/marketing
  pages are live at https://anystupididea.com/support and https://anystupididea.com/aqi_me.
- **Android:** the same app builds and runs natively; betas ship via Firebase App
  Distribution while the Google Play organization account clears D-U-N-S verification, then
  Play Store submission.

All web milestones (M0–M4) complete, plus follow-ups: city/state search (with a comma-less
fallback), default locations, bundled fonts, hourly auto-refresh, named timezones,
social-preview cards, grid/list views with drag-and-drop reordering, a help sheet +
pollutant glossary, a how-to-video call-out, a persisted theme, a sticky footer, the AQI
scale bar, automated CI/CD, and the multi-platform (Android + iOS) expansion. See the
technical design doc for the full picture.
