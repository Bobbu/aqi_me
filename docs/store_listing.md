# AQI Me — Store Listing (Google Play, draft)

Copy-paste-ready content for the Play Console listing. Character limits noted.
Draft for review — tweak the voice to taste before publishing.

---

## App name (max 30)
```
AQI Me
```
*(Room to spare — a more discoverable variant if you want it: `AQI Me — Air Quality` (20).)*

## Short description (max 80)
```
Live air quality for up to 20 places on one calm, private dashboard.
```
*(69 chars. Alt: `Track the air quality of the places you care about — no login, no ads.` = 70)*

## Full description (max 4000)
```
AQI Me shows the current Air Quality Index (AQI) for the places you care about —
home, family across the country, your next trip — all on one clean screen.

Add up to 20 locations by name (“Denver, CO”, “London, UK”) or GPS coordinates,
and see each one’s live reading color-coded on the US EPA scale, from Good (green)
to Hazardous (maroon). A single glance tells you whether the air is clear or
whether somewhere needs your attention.

WHAT YOU GET
• Current AQI for up to 20 locations, refreshed hourly
• An at-a-glance scale bar that plots every location on the AQI spectrum, so you
  can see how each place compares — and how close any is to the next level
• Tap a dot to jump straight to that location’s card
• Each card shows the AQI value and category, the dominant pollutant (PM2.5, O₃,
  and more), the temperature, and the local time of the reading
• Grid or list view, with drag-and-drop reordering
• A built-in guide to the AQI scale and what each pollutant means
• Light and dark themes

PRIVATE BY DESIGN
• No account. No sign-up. Just open it and go.
• No ads. No trackers. No analytics.
• Your list of locations is stored only on your device — never uploaded to us.
• Air-quality data comes from the free, open Open-Meteo service.

AQI Me is a calm instrument for a simple question: how’s the air, right now, in
the places that matter to me?

Also available on the web at aqi-me.anystupididea.com.
```

## Category & tags
- **Category:** Weather
- **Tags (pick up to 5 in console):** Weather, Air quality, Health, Pollution, Dashboard
- **Contact email:** <your support email>
- **Website:** https://aqi-me.anystupididea.com
- **Privacy policy URL:** <your existing Privacy page URL> ✅ (already live)

---

## Content rating (IARC questionnaire → expected "Everyone / PEGI 3")
Answer the questionnaire honestly; for this app the answers are all "no":
- Violence / scary content: **No**
- Sexual content, profanity: **No**
- Controlled substances, gambling (real or simulated): **No**
- User-generated content / user-to-user communication: **No**
- Shares user location with other users: **No**
- Digital purchases: **No**
- Ads: **No**

---

## Data safety form (review carefully — one nuanced item)
The app has **no account, no analytics, no ads, no advertising ID**, and stores the
location list **only on the device**. The one thing to declare honestly:

**Location.** AQI Me does **not** request device-location permission — you type the
place yourself. But to fetch a reading, the app sends the **coordinates you’re
checking** to the Open-Meteo API. That's data leaving the device to a third party,
so the conservative, honest declaration is:

- **Does your app collect or share user data?** Yes (location, for the API call).
- **Data type:** Location → *Approximate location* (the queried place, not tracked GPS).
- **Collected or shared?** *Shared* (with Open-Meteo), for **App functionality**.
- **Processed ephemerally?** Yes — used for the request, not stored by us.
- **Required or optional?** Required (it’s how the reading is fetched).
- **Linked to identity?** No. **Used for tracking?** No.
- Everything else (personal info, identifiers, financial, contacts, etc.): **not collected.**

> Note: because there’s no location *permission* and the user enters the place
> manually, some would declare "no data collected." Sending coordinates to a third
> party is why the safe answer is to declare Location as *shared for functionality*.
> Worth a 2-minute read of Google’s Data safety definitions before you submit.

**App access:** no special permissions beyond INTERNET (not a declarable permission
in the form).

---

## Graphic assets checklist
| Asset | Spec | Status |
|-------|------|--------|
| App icon | 512×512 PNG, no alpha | from logo — to export |
| Feature graphic | 1024×500 PNG/JPG | **to create** (required by Play) |
| Phone screenshots | 2–8, PNG/JPG, 320–3840px, **≤ 2:1 ratio** | generating (padded to 1200×2400) |
| Tablet screenshots | optional | skip for v1 |

## Release notes (first release)
```
First release of AQI Me — live air quality for up to 20 places, private by
design. No account, no ads.
```
