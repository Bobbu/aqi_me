# AQI.me — Technical Design Document

**Status:** Shipped — live at https://aqi-me.anystupididea.com
**Author:** Robert Daly
**Last updated:** 2026-07-19
**Related:** [PRD.md](./PRD.md)

---

## 1. Overview

Technical design for AQI.me: a **Flutter Web** single-page app that lets anonymous users
track current AQI for up to 20 locations. The app is **client-only** — it calls the
free, key-less **Open-Meteo** APIs directly from the browser, persists state per-device
in the browser, and ships as **static files** on S3 + CloudFront, served at
**`https://aqi-me.anystupididea.com`**. Deployed via a single CDK stack (scorched-earth,
one-click, no console, no secrets).

**No install required.** It's a website: users just visit the URL. We ship a web manifest
so it's *optionally* installable ("Add to Home Screen"), but that is never required —
opening the link is the whole experience.

## 2. Guiding Principles

- **No backend, no secrets.** Everything runs client-side; the data provider needs no
  API key. Nothing to rotate, nothing in the AWS console.
- **One-click, scorched-earth deploy.** `cdk deploy` rebuilds the entire system —
  including DNS and TLS — from nothing; `cdk destroy` tears it all down.
- **Zero warnings.** `flutter analyze` must be clean before any release; lints in CI.
- **Provider-agnostic data layer.** Swapping Open-Meteo for another source touches one
  package, never the UI.
- **The air supplies the color.** Chrome is neutral and precise; the AQI category colors
  are the entire chromatic story (see §4).

## 3. Technology Stack

| Concern | Choice | Notes |
|--------|--------|-------|
| UI framework | **Flutter Web** | Single codebase; renders in-browser, no install. |
| Renderer | **CanvasKit** (default) → evaluate **HTML/`skwasm`** | CanvasKit = fidelity; HTML = smaller payload/faster first paint. Decide via §13. |
| Language | Dart (stable channel) | — |
| State mgmt | **Riverpod** | Testable, compile-safe, good async (`AsyncValue`). |
| HTTP | `dio` (or `http`) | `dio` for interceptors/retry; either is fine. |
| Local persistence | `shared_preferences` | Stores the location list as JSON, per device. |
| Fonts | `google_fonts` | Space Grotesk / Inter / IBM Plex Mono (see §4). |
| JSON | `json_serializable` + `freezed` | Immutable models, generated (de)serialization. |
| Routing | Minimal / single route | One page; deep-link/share is a future item. |
| Lint | `flutter_lints` (or `very_good_analysis`) | Zero-warning gate. |
| Infra | **AWS CDK (TypeScript)** | S3 + CloudFront + OAC + Route53 + ACM. |
| CI/CD | GitHub Actions | Build web → `cdk deploy`. |

### Resolved PRD open questions (recommendations)
1. **Front-end:** Flutter Web (decided).
2. **Auto-refresh cadence:** **60 min** default (data is hourly; avoids wasted calls).
3. **Pollutant breakdown:** Show **AQI + dominant pollutant** on the card; full
   breakdown (PM2.5/PM10/O₃/NO₂/SO₂/CO) in an expandable detail.
4. **Index:** **US AQI** everywhere for v1 (consistent scale); regional auto-select is
   post-v1.
5. **Custom domain:** **Yes — `aqi-me.anystupididea.com`**, provisioned in the CDK stack
   (Route53 + ACM). See §12.
6. **Shareable URL:** Post-v1.

## 4. Design Language & Visual Direction

**Thesis — "An instrument for the air."** The interface is a calm, precise monitoring
panel; it contributes almost no color of its own. Every bit of chroma on screen comes
from the **AQI category** of the places you're watching, so the page literally takes on
the color of your world's air. This keeps the mandated EPA color coding front-and-center
*as the design*, not as a decorative afterthought — and it deliberately avoids the
generic "cream + serif + terracotta" / "black + acid accent" AI-design defaults.

### 4.1 Palette

Neutral chrome (cool, instrument-like — not cream, not pure black):

| Token | Light ("Porcelain") | Dark ("Observatory") |
|-------|--------------------|--------------------|
| Base background | `#F5F7FA` | `#0E1116` |
| Surface (card) | `#FFFFFF` | `#161B22` |
| Ink (primary text) | `#12161C` | `#E7ECF2` |
| Muted text | `#5B6572` | `#8A94A3` |
| Hairline / border | `#E2E6EC` | `#232A33` |

**AQI category colors** — hues stay within EPA identity (recognizable at a glance) but
are tuned for UI cohesion and **WCAG AA** text contrast. Each category has a *solid*
(badge, number, spine) and a *haze* (soft card wash):

| AQI | Category | EPA ref | Solid | Haze |
|-----|----------|---------|-------|------|
| 0–50 | Good | `#00E400` | `#3DAE7A` | soft sage wash |
| 51–100 | Moderate | `#FFFF00` | `#D9A400` | pale gold wash |
| 101–150 | Unhealthy (Sensitive) | `#FF7E00` | `#F2843A` | warm amber wash |
| 151–200 | Unhealthy | `#FF0000` | `#E5484D` | rose wash |
| 201–300 | Very Unhealthy | `#8F3F97` | `#8E5BD9` | violet wash |
| 301–500 | Hazardous | `#7E0023` | `#9B1C46` | deep maroon wash |

> Accessibility rule: **never color-only.** Every card always states the numeric AQI and
> the category label in text; color is reinforcement, not the sole signal. Text sits on
> chrome/ink (not on the haze) to hold AA contrast.

### 4.2 Typography

Deliberately an *instrument-readout* pairing, not a magazine pairing:

- **Display — Space Grotesk** (600/700): location names, section headers. Technical,
  slightly mechanical character.
- **Body/UI — Inter** (400/500): labels, secondary detail, buttons. Uppercase, tracked
  Inter for eyebrows/labels (e.g. `AS OF 2:00 PM · DENVER`).
- **Data — IBM Plex Mono** (500, **tabular figures**): the large AQI number and pollutant
  values. The monospaced readout is the memorable type move — it makes each card read
  like a gauge.

Scale (indicative): AQI number 56–64px mono · location name 20–22px display · body 14px ·
eyebrow/label 11–12px uppercase, +0.08em tracking.

### 4.3 Signature elements

1. **The air-tinted card (primary signature).** Each location card carries a soft radial
   **haze** in its category color; haze density scales with severity — *clear and crisp*
   for Good, *dense and smoggy* for Hazardous — so worse air literally looks heavier. A
   thin vertical **color spine** on the card's leading edge encodes category for fast
   scanning across 20 cards.
2. **The air ribbon.** A slim horizontal strip at the top of the page — one segment per
   tracked location, in its category color — giving an at-a-glance spectrum of your whole
   world's air before you read a single number.

### 4.4 Layout (ASCII wireframe)

```
┌───────────────────────────────────────────────────────────────┐
│  AQI·ME                                        ☀/☾   ⟳ refresh  │  ← quiet chrome header
│  ▓▓▓░░░▓▓▓▓▒▒▒░░░  (air ribbon: per-location category colors)   │
├───────────────────────────────────────────────────────────────┤
│  [ add a city, or  39.74, -104.99            ]        12 / 20   │  ← single smart input
│                                                                 │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐         │
│  ┃ DENVER, CO    │ ┃ TOKYO, JP     │ ┃ DELHI, IN     │         │  ← spine = category
│  ┃  42           │ ┃  78           │ ┃  164          │         │  ← IBM Plex Mono readout
│  ┃  GOOD         │ ┃  MODERATE     │ ┃  UNHEALTHY    │         │
│  ┃  PM2.5 · 71°F │ ┃  O₃ · 66°F    │ ┃  PM2.5 · 95°F │         │  ← haze intensifies →
│  ┃  as of 2:00PM │ ┃  as of 3:00AM │ ┃  as of 11:30PM│         │
│  └───────────────┘ └───────────────┘ └───────────────┘         │
│         (responsive grid → single column on mobile)             │
└───────────────────────────────────────────────────────────────┘
```

### 4.5 Motion (restrained)

- AQI number **counts up** on first load / refresh.
- Haze has a very slow ambient drift; the color spine has none.
- Everything gated by `prefers-reduced-motion` — reduced mode snaps numbers and freezes
  the haze. Chrome stays still; only the cards ever move.

## 5. High-Level Architecture

```
┌───────────────────────────── Browser ─────────────────────────────┐
│  Flutter Web app (static bundle from CloudFront)                    │
│                                                                    │
│  UI (widgets)  ──▶  Controllers (Riverpod)  ──▶  Repository        │
│        ▲                     │                       │             │
│        │                     ▼                       ▼             │
│   AsyncValue          LocationStore            AqiService (iface)  │
│   render state       (shared_preferences)      └── OpenMeteoService│
│                                                                    │
└──────────────────────────────┬─────────────────────────────────────┘
                               │ HTTPS (no key, CORS-enabled)
                               ▼
                    Open-Meteo APIs (Air Quality / Forecast / Geocoding)
```

- **UI** renders from Riverpod providers exposing `AsyncValue<LocationReading>`.
- **Repository** coordinates geocoding + AQI + weather and applies caching.
- **AqiService** is the provider-agnostic interface; `OpenMeteoService` implements it.
- **LocationStore** persists the user's list locally (per device).

## 6. Package / Module Structure

```
lib/
  main.dart
  app.dart                      # MaterialApp + theme (§4 tokens)
  core/
    aqi_scale.dart              # AQI → category + solid/haze color (EPA, §4.1)
    theme.dart                  # chrome palette, typography, light/dark
    result.dart                 # typed error/result helpers
    coord_parser.dart          # detect & parse "lat, lon"
  models/
    location.dart               # user-entered location (freezed)
    geocode_result.dart
    aqi_reading.dart            # value, category, dominant pollutant, timestamp
    weather_reading.dart
    location_reading.dart       # composed: location + aqi + weather + local time
  data/
    aqi_service.dart            # abstract interface (getAqi/geocode/getWeather)
    open_meteo/
      open_meteo_service.dart
      open_meteo_dtos.dart      # JSON DTOs (json_serializable)
    location_store.dart         # shared_preferences persistence
    location_repository.dart    # orchestration + caching
  state/
    locations_controller.dart   # add/remove/reorder, enforces 20 cap
    reading_providers.dart      # per-location AsyncValue providers + refresh
  ui/
    home_page.dart
    widgets/
      air_ribbon.dart           # §4.3 aggregate strip
      add_location_field.dart
      disambiguation_sheet.dart # pick among ambiguous geocode matches
      location_card.dart        # spine + haze + mono readout (§4.3)
      aqi_badge.dart
      pollutant_details.dart
      empty_state.dart
      error_card.dart
```

## 7. Data Model

```dart
// Persisted per user-added location (input, not the reading).
@freezed
class Location {
  const factory Location({
    required String id,          // uuid
    required double lat,
    required double lon,
    required String label,       // resolved display name
    String? admin1,              // state/region
    String? country,
    String? timezone,            // IANA, from geocoding (for local time)
    required LocationSource source, // typedName | coordinates
  }) = _Location;
}

@freezed
class AqiReading {
  const factory AqiReading({
    required int usAqi,
    required AqiCategory category,
    String? dominantPollutant,   // e.g. "pm2_5"
    Map<String, double>? pollutants, // pm2_5, pm10, o3, no2, so2, co
    required DateTime observedAt, // UTC timestamp of the hourly reading
  }) = _AqiReading;
}

// LocationReading = Location + AqiReading + optional WeatherReading + localTime
```

`AqiCategory` is an enum (`good … hazardous`) with helpers for label + solid/haze color,
derived in `core/aqi_scale.dart` from the EPA breakpoints (§4.1).

## 8. Data Provider Integration (Open-Meteo)

All endpoints are **GET**, **no auth**, **CORS-enabled**. Base hosts:

| Purpose | Endpoint |
|---------|----------|
| Geocoding | `https://geocoding-api.open-meteo.com/v1/search?name={q}&count=5` |
| Air Quality | `https://air-quality-api.open-meteo.com/v1/air-quality` |
| Weather | `https://api.open-meteo.com/v1/forecast` |

**Air Quality request (current AQI):**
```
GET /v1/air-quality
  ?latitude={lat}&longitude={lon}
  &current=us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide,carbon_monoxide
  &timezone=auto
```
Prefer the `current=` block for "latest" values; fall back to the newest `hourly` entry
if `current` is unavailable. `observedAt` comes from the response time field.

**Weather request (temperature, nice-to-have):**
```
GET /v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m&timezone=auto
```

**Local time:** derive from the location's IANA `timezone` (returned by geocoding /
`timezone=auto`) rather than trusting the client clock.

### 8.1 Service interface

```dart
abstract class AqiService {
  Future<List<GeocodeResult>> geocode(String query);
  Future<AqiReading> getAqi(double lat, double lon);
  Future<WeatherReading> getWeather(double lat, double lon);
}
```
`OpenMeteoService` implements it. A future `WaqiService` / `OpenAqService` can drop in
behind the same interface with no UI changes (per PRD §8).

## 9. Core Flows

### 9.1 Add a location
1. User submits the input string.
2. `coord_parser` tests for `lat, lon` (valid ranges −90..90 / −180..180).
   - **Coordinates** → build `Location(source: coordinates)` directly.
   - **Text** → `geocode(query)`:
     - 0 results → error ("couldn't find that place").
     - 1 result → use it.
     - >1 → show `disambiguation_sheet` (name, admin1, country) to pick.
3. Enforce the **20-cap** and **dedupe** (round coords to ~3 decimals ≈ 100 m).
4. Persist via `LocationStore`; trigger a reading fetch.

### 9.2 Fetch a reading
1. Provider for the location requests AQI (+ weather) from the repository.
2. Repository checks cache (freshness window, §10); returns cached or fetches.
3. UI renders `AsyncValue`: loading → data (card) / error (error card w/ retry).
4. One card's failure is isolated — never blocks siblings.

### 9.3 Refresh
- **Manual:** per-card and global refresh buttons invalidate the relevant providers.
- **Auto:** a timer invalidates readings every **60 min** while the tab is visible
  (pause when `document.hidden`).

### 9.4 Restore on load
- Read the persisted list from `shared_preferences`, hydrate controllers, fetch readings.

## 10. Caching, Rate Limits & Resilience

- **Client cache:** keep the last reading per location with its `observedAt`; skip
  re-fetch inside the freshness window (default 60 min). Manual refresh forces a fetch.
- **Batching/throttling:** stagger initial fetches (small concurrency limit, e.g. 4) to
  stay well within Open-Meteo fair-use limits for 20 locations.
- **Retry:** exponential backoff on transient network/5xx (max ~3 tries) via HTTP
  interceptor; surface a clean error card after exhaustion.
- **Isolation:** per-location error handling; the grid degrades gracefully.
- **Offline:** show last-known readings from cache with a "stale" indicator.

## 11. Error Handling & Empty States

| Condition | UX |
|-----------|-----|
| Geocode: no match | Inline error under the input. |
| Geocode: ambiguous | Disambiguation sheet. |
| 20-cap reached | Disable add; explain. |
| Duplicate location | Toast: "already tracking that spot." |
| AQI fetch failed | Error card with retry; siblings unaffected. |
| No locations yet | Empty state with example ("Denver, CO" / `39.7,-104.9`). |
| Offline / stale | Cached values + "as of …" stale badge. |

Copy voice: plain, active, non-apologetic. Errors say what happened and how to fix it;
the empty state is an invitation to add the first place.

## 12. Deployment & Infrastructure (CDK)

**Goal:** one command rebuilds everything from scorched earth — hosting, CDN, DNS, and
TLS — with nothing manual in the console.

- **Stack (`infra/`, CDK TypeScript):**
  - Private **S3 bucket** for the built web bundle (`build/web`), `autoDeleteObjects`.
  - **CloudFront** distribution with **Origin Access Control (OAC)** — bucket stays
    private; only CloudFront reads it. Redirect HTTP → HTTPS.
  - **Custom domain:**
    - `HostedZone.fromLookup` for **`anystupididea.com`** (assumed already in Route53 —
      see prerequisite below).
    - **ACM certificate** for `aqi-me.anystupididea.com`, DNS-validated automatically
      via Route53. **Must be in `us-east-1`** (CloudFront requirement) — if the app stack
      runs in another region, provision the cert in a `us-east-1` sub-stack and wire it
      with `crossRegionReferences: true`.
    - CloudFront **alternate domain name (CNAME)** = `aqi-me.anystupididea.com`, viewer
      cert = the ACM cert.
    - Route53 **A + AAAA alias** records → the CloudFront distribution.
  - **SPA rewrite:** custom error responses map 403/404 → `/index.html` (200) so the
    single page serves all paths.
  - **`s3deploy.BucketDeployment`** uploads `build/web` and **invalidates** CloudFront on
    each deploy.
  - Cache policy: long-cache hashed assets, **no-cache `index.html`** /
    `flutter_service_worker.js` so releases go live immediately.
- **Prerequisite (satisfied ✓):** the **`anystupididea.com` hosted zone exists in this
  account's Route53**. CDK looks it up rather than creates it (registrar + apex zone are
  account-level and shared across your subdomains); everything else in the stack is fully
  reproducible.
- **Deploy pipeline:**
  ```bash
  flutter build web --release        # (choose renderer per §13)
  cd infra && npm ci && cdk deploy    # hosting + DNS + TLS, uploads + invalidates
  ```
- **Result:** visiting **`https://aqi-me.anystupididea.com`** loads the app — no install,
  no account. `cdk destroy` removes the bucket, distribution, cert, and DNS records
  (leaving the shared apex zone intact).
- **No secrets anywhere** — the data provider is key-less, so there are no env vars,
  Secrets Manager entries, or `.env` files.

## 13. Renderer & Performance Notes

- Start with **CanvasKit** for visual fidelity (the haze/gradient signature renders
  crisply); measure first-paint and bundle size.
- If initial load is too heavy for a lightweight utility, evaluate the **HTML renderer**
  (or `skwasm`) — decision recorded here once measured.
- Lazy-load pollutant detail; keep the 20-card grid virtualization-friendly.
- Precache Flutter assets via the generated service worker for fast repeat visits.

## 14. Testing & Quality Gates

- **Unit:** `coord_parser`, `aqi_scale` breakpoints/colors, DTO (de)serialization,
  dedupe logic, cache freshness.
- **Service:** `OpenMeteoService` against recorded fixture responses (mocked HTTP).
- **Widget:** add-location flow (coords vs. text vs. ambiguous), card states
  (loading/data/error/stale), 20-cap behavior, light/dark theming.
- **Gates (CI):** `flutter analyze` **zero warnings**, `dart format --set-exit-if-changed`,
  `flutter test` green — all required before deploy.

## 15. Security & Privacy

- No accounts, no PII, no tracking/analytics in v1.
- Only outbound calls are to Open-Meteo over HTTPS.
- Location list stored **locally per device**; never transmitted to us.
- No secrets in the client bundle (nothing to leak — key-less provider).

## 16. Milestones — all shipped ✅

1. **M0 – Scaffold** ✅ Flutter Web project, lints, models, `aqi_scale`, theme tokens (§4),
   zero-warning analyze gate.
2. **M1 – Data layer** ✅ `OpenMeteoService` + repository + fixtures/tests.
3. **M2 – Core UX** ✅ add (coords/text/disambiguation), card grid, 20-cap, persistence.
4. **M3 – Design & polish** ✅ air-tinted cards + spine + haze, air ribbon, mono readout,
   count-up animation, light/dark toggle, refresh/caching, error/empty states, temp,
   reduced motion, logo + favicon.
5. **M4 – Deploy** ✅ CDK stack (S3 + CloudFront + OAC + Route53 + ACM), live at
   `aqi-me.anystupididea.com`, GitHub Actions CI/CD (OIDC).

### Shipped beyond the original plan

- **City/State search** — split `"Chicago, IL"` into name + region; match region against
  each candidate's admin1/country (US state abbreviations expanded, country synonyms).
  See `core/region_matching.dart`.
- **Default locations** — seed Washington D.C. + Lake Barrington, IL for first-time
  visitors; never re-seeded once the user edits the list (`data/default_locations.dart`,
  `LocationStore.hasSavedList`).
- **Bundled fonts** — Space Grotesk / Inter / IBM Plex Mono shipped as OFL assets
  (`google_fonts` removed), honoring the "only Open-Meteo outbound calls" goal (§15).
- **Hourly auto-refresh** — `HomePage` timer + lifecycle catch-up on resume (§9.3).
- **Named timezones** — each "as of" time shows the DST-aware zone abbreviation (EDT,
  CDT, MST, BST, …) derived from the IANA zone via the `timezone` package, with the
  provider's `GMT±x` label as fallback.
- **Social preview** — Open Graph + Twitter card tags with a 1200×630 logo card
  (`web/og-image.png`) so pasted links render a rich preview.
- **CI/CD** — `.github/workflows/deploy.yml` (analyze/test/build → `cdk deploy`) and
  `infra/AqiMeCicdStack` (GitHub OIDC provider + scoped deploy role).

### Operational learnings (worth remembering)

- **CDK `BucketDeployment` OOM:** the default 128 MB deploy Lambda runs out of memory
  syncing the ~38 MB CanvasKit bundle, hanging the deploy. Fixed with `memoryLimit: 1024`
  on both deployments (§12).
- **GitHub OIDC custom subject:** this repo customizes its OIDC `sub` to embed numeric
  owner/repo IDs (`repo:Bobbu@426328/aqi_me@1305205082:ref:...`), so the trust policy
  matches `sub` with wildcards for the IDs plus a `repository` equality check. AWS also
  requires a `sub`/`job_workflow_ref` condition on GitHub OIDC roles.
- **Cache/releases:** static assets are immutable-cached; `index.html` +
  `flutter_service_worker.js` are `no-cache` and every deploy invalidates CloudFront, so
  new visitors get the update immediately and returning visitors update via the Flutter
  service worker (version.json) on their next visit.

## 17. Technical Questions — resolved

1. **Renderer:** shipped on **CanvasKit** (the default). First paint is fine for this
   utility and the haze/gradient renders crisply; no need to switch to the HTML renderer.
2. **`dio` vs. `http`:** shipped **`dio`** (injectable, interceptor-friendly; tests use a
   fake `HttpClientAdapter`).
3. **Persistence:** shipped **`shared_preferences`** (a single JSON string) — plenty for a
   ≤20-item list.
4. **Route53:** yes — the `anystupididea.com` zone is in the account; `HostedZone.fromLookup`
   makes the stack fully reproducible.
5. **Fetch concurrency:** not throttled — each location's reading is an independent Riverpod
   `FutureProvider`, comfortably within Open-Meteo fair-use for ≤20 locations. Revisit only
   if rate-limiting appears.
