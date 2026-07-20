# AQI Me

A simple, beautiful one-page web app to track **current Air Quality Index (AQI)** for up
to **20 locations** at once — added by city/state/country or GPS coordinates. No account,
no install: just visit the site.

**Live:** https://aqi-me.anystupididea.com

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

- **Flutter Web** — single codebase, runs in the browser, nothing to install. Fonts are
  bundled, so the only outbound calls are to Open-Meteo.
- **[Open-Meteo](https://open-meteo.com/)** — free, key-less APIs for air quality,
  weather, and geocoding. No secrets in the app.
- **AWS CDK (TypeScript)** — private S3 + CloudFront (OAC) + Route53 + ACM, all in
  `infra/`. `cdk deploy` builds everything from scorched earth; `cdk destroy` tears it
  down. No console, no secrets.
- **CI/CD** — every push to `main` runs analyze + tests + build and auto-deploys via
  GitHub Actions using OIDC (no stored AWS keys). See [`.github/workflows/deploy.yml`].

## Deploy

```bash
./deploy.sh          # build Flutter web + cdk deploy (one-click, local)
```

Or just push to `main` and let CI/CD deploy it. See [infra/README.md](./infra/README.md).

## Docs

- [Product Requirements (PRD)](./docs/PRD.md)
- [Technical Design](./docs/TECH_DESIGN.md)

## Status

**Shipped and live** at https://aqi-me.anystupididea.com. All milestones (M0–M4) complete,
plus follow-ups: city/state search (with a comma-less fallback), default locations, bundled
fonts, hourly auto-refresh, named timezones, social-preview cards, grid/list views with
drag-and-drop reordering, a help sheet + pollutant glossary, a how-to-video call-out, a
persisted theme, a sticky footer, and automated CI/CD. See the technical design doc for the
full picture.
