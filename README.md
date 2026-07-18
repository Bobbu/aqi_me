# AQI.me

A simple, beautiful one-page web app to track **current Air Quality Index (AQI)** for up
to **20 locations** at once — added by city/state/country or GPS coordinates. No account,
no install: just visit the site.

**Live:** https://aqi-me.anystupididea.com *(pending first deploy)*

## What it does

- Track up to 20 places; see current AQI (≤ 1 hour old where available), color-coded on
  the US EPA scale.
- Add locations by name (*"Denver, CO"*) or coordinates (*`39.74, -104.99`*).
- Temperature and local time shown per location (nice-to-haves).
- Your list is saved locally, per device — nothing is sent to us.

## How it's built

- **Flutter Web** — single codebase, runs in the browser, nothing to install.
- **[Open-Meteo](https://open-meteo.com/)** — free, key-less APIs for air quality,
  weather, and geocoding. No secrets in the app.
- **AWS CDK (TypeScript)** — S3 + CloudFront + Route53 + ACM, one-click deploy to
  `aqi-me.anystupididea.com`. `cdk deploy` builds it all from scorched earth;
  `cdk destroy` tears it down.

## Docs

- [Product Requirements (PRD)](./docs/PRD.md)
- [Technical Design](./docs/TECH_DESIGN.md)

## Status

Early — docs complete, implementation scaffolding next. See the milestones in the
technical design doc.
