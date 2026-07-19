# AQI.me — Product Requirements Document

**Status:** Shipped — v1 live at https://aqi-me.anystupididea.com
**Author:** Robert Daly
**Last updated:** 2026-07-19

---

## 1. Summary

AQI.me is a single-page web app that lets **anonymous** users add up to **20 locations**
(by city / state / country name, or by raw GPS coordinates) and see the **current Air
Quality Index (AQI)** for each — refreshed to within the last hour where the data source
allows. Local temperature and local time are shown as nice-to-have secondary details.

No login, no signup, no personal data collection. All AQI data comes from a **free,
key-less API** so the app can run entirely client-side with no secrets and no backend
to operate.

## 2. Goals

- Let anyone, with zero friction (no account), monitor AQI across many places at once.
- Support **up to 20 simultaneous locations**.
- Show **current AQI** (ideally ≤ 1 hour old) per location, color-coded by severity.
- Accept locations as **city, state, country** *or* **GPS coordinates**.
- Persist the user's list **locally** (browser storage) so it survives a refresh.
- Cost **$0** to run at small scale — free data provider, static hosting.

## 3. Non-Goals (v1)

- User accounts, auth, or cross-device sync.
- Historical charts / trends / forecasts.
- Push notifications or threshold alerts.
- Native mobile apps (responsive web only).
- A backend database or server-side rendering.

## 4. Target Users

Anyone curious or health-conscious about air quality across multiple places they care
about — e.g. someone tracking home, family in another state, and a travel destination —
who wants a quick glance without creating an account.

## 5. User Stories

1. As a visitor, I can type a place ("Denver, CO, USA" or "Tokyo, Japan") and see its
   current AQI within seconds.
2. As a visitor, I can enter GPS coordinates (`39.7392, -104.9903`) for places without a
   clean name (a trailhead, a rural area).
3. As a visitor, I can add up to 20 locations and see them all together at a glance.
4. As a visitor, I can remove a location I no longer care about.
5. As a returning visitor, my list is still there when I come back (local persistence).
6. As a visitor, I can refresh to get the latest readings.
7. As a visitor, I can optionally see the temperature and local time for each location.

## 6. Functional Requirements

### 6.1 Adding locations
- Single input box accepts either a **place string** or **coordinates**.
  - Coordinates detected by pattern (`lat, lon` within valid ranges).
  - Place strings are geocoded to lat/lon (see §8).
- If a place string is ambiguous, show up to ~5 matches for the user to pick from
  (name, admin region, country) so "Springfield" resolves correctly.
- Enforce the **20-location cap**; when reached, disable adding and explain why.
- Reject / de-dupe locations that resolve to (approximately) the same coordinates.

### 6.2 Displaying locations
- Each location renders as a **card** showing:
  - **Required:** resolved location name, **current AQI value**, AQI category label
    (e.g. *Good / Moderate / Unhealthy for Sensitive Groups / …*), and severity color.
  - **Timestamp** of the reading (e.g. "as of 2:00 PM local").
  - **Nice-to-have:** current temperature; local time at the location.
- Cards laid out responsively (grid on desktop, stacked on mobile).
- Optionally surface the **dominant pollutant** (e.g. PM2.5) when available.

### 6.3 Refresh
- **Manual refresh** button (per-card and/or global).
- **Auto-refresh** on a sensible interval (e.g. every 30–60 min) while the tab is open.
- Cache responses client-side and avoid redundant calls within the freshness window.

### 6.4 Managing the list
- Remove a location (X on the card).
- **Reorder** by drag-and-drop (shipped — was a v1 nice-to-have), in both grid and list
  views; order is persisted.
- **Grid or list view**, toggled and persisted per device.
- List persisted in `localStorage`; no server round-trip needed to restore it.

### 6.5 States & errors
- Loading state per card while fetching.
- Clear error state if a location can't be resolved or the API is unavailable, with a
  retry affordance. One failing card must not break the others.
- Empty state (no locations yet) with a short prompt and an example.

## 7. AQI Scale & Presentation

- Use the **US EPA AQI** scale as the primary index (0–500), with standard categories
  and colors:

  | AQI | Category | Color |
  |-----|----------|-------|
  | 0–50 | Good | Green |
  | 51–100 | Moderate | Yellow |
  | 101–150 | Unhealthy for Sensitive Groups | Orange |
  | 151–200 | Unhealthy | Red |
  | 201–300 | Very Unhealthy | Purple |
  | 301–500 | Hazardous | Maroon |

- Always show units/label so a bare number is never ambiguous.
- Consider offering **European AQI** as an alternate later; out of scope for v1.

## 8. Data Source (Free API)

**Primary recommendation: [Open-Meteo](https://open-meteo.com/)** — chosen because it is
free, requires **no API key and no signup**, is CORS-friendly (works from a static
client-only app), and covers all three needs with one provider:

- **Air Quality API** — hourly **US AQI** and European AQI, plus PM2.5, PM10, ozone,
  NO₂, SO₂, CO. Enables "current, within the hour" readings.
- **Weather / Forecast API** — current temperature (nice-to-have).
- **Geocoding API** — resolves city / state / country strings to lat/lon and returns
  the location's timezone (used for local time, a nice-to-have).

> Note: Open-Meteo's free tier is for non-commercial use with fair-use rate limits —
> comfortably fine for a personal one-page app. No credentials to store, which keeps the
> app fully static and matches our "no secrets, one-click deploy" preference.

**Alternatives considered** (documented in case we outgrow Open-Meteo):
- **WAQI / aqicn.org** — real-time station-based AQI; free token via email signup.
  Great for actual monitoring-station readings, but requires a token.
- **OpenAQ** — open raw measurements; now requires an API key.
- **IQAir / AirVisual** — polished data; free tier is key-gated and call-limited.
- **Google Air Quality API** — high quality but paid.

**API-swap requirement:** wrap the provider behind a small internal interface
(`getAqi(lat, lon)`, `geocode(query)`, `getWeather(lat, lon)`) so a future provider swap
touches one module, not the UI.

## 9. Architecture (proposed)

- **Client-only single-page app**, static-hosted (e.g. S3 + CloudFront), no backend,
  no database, no secrets — aligns with our scorched-earth, one-click CDK deploy stance.
- All API calls made directly from the browser to Open-Meteo (key-less + CORS).
- State (the location list) lives in `localStorage`.
- If rate limiting or CORS ever forces it, add a thin proxy/caching Lambda later —
  explicitly **not** needed for v1.

*(Framework choice — Flutter Web vs. a JS SPA — to be decided in a follow-up technical
design doc.)*

## 10. Success Metrics

- A user can add a location and see a valid AQI reading in **< 5 seconds**.
- Readings are **≤ 1 hour old** for supported locations.
- App handles **20 locations** without noticeable jank.
- **$0** infra cost at personal-use scale.

## 11. Decisions (were open questions)

1. **Front-end:** Flutter Web.
2. **Auto-refresh cadence:** 60 min.
3. **Pollutant breakdown:** show the dominant pollutant on each card (full breakdown is
   post-v1).
4. **Index:** US AQI everywhere; regional (US vs. European) auto-selection is post-v1.
5. **Shareable URL:** deferred to post-v1.

## 12. Shipped in v1 (beyond the core requirements)

- **First-run defaults:** new visitors start with Washington D.C. and Lake Barrington, IL.
- **"City, State" search:** e.g. `Chicago, IL`, `Washington, DC`, `London, UK` — with a
  **comma-less fallback** so `Greensboro GA` also resolves.
- **Named timezones:** each reading time shows its zone (e.g. *as of 2:00 AM EDT*).
- **Grid or list view** with **drag-and-drop reordering** (both persisted).
- **Help sheet + pollutant glossary:** an in-app key to the AQI scale and pollutant codes
  (PM2.5, PM10, O₃, NO₂, SO₂, CO), plus a dismissible how-to-video call-out.
- **Persisted light/dark toggle**, hourly auto-refresh, wrapping card text (long place
  names never truncate), a sticky footer, bundled fonts (fully self-contained), and rich
  social-preview cards when the link is shared.
- **One-click + automated deploys:** `cdk deploy` / `./deploy.sh`, and CI/CD on push.

## 13. Future Ideas (post-v1)

- Threshold alerts / notifications.
- Historical trends and short-term forecast.
- Shareable/bookmarkable location lists via URL.
- Map view alongside the card list.
- Regional AQI index auto-selection; full pollutant breakdown on the card.
- **Pollen levels — on ice.** Open-Meteo's pollen data is Europe-only; global coverage
  would require a keyed provider (e.g. Google's Pollen API) plus a small proxy, which cuts
  against the key-less / no-login design. Parked unless we want European-only coverage.
