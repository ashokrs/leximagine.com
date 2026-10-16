# Plan — "Immersive Shopping" supertab

Not published: the leading underscore makes Jekyll skip this file.
Created: 2026-10-16 · Status: **phases 0–4 committed locally 2026-10-16 (35423bb, f5bdc84, 63f34cd); not pushed.** Phase 3 deviation: the supertab strip sits just above `<header>` instead of inside it, so the header block stays byte-identical.

---

## 0. Hard rules (non-negotiable)

Tickster Pet Scan is live on the Apple App Store and Google Play. Its published
URLs are registered with both stores and **must never change** — not the URL, not
the content, not the header.

**Protected — zero edits, ever:**

| Path | Why |
|---|---|
| `privacy/index.html` | Privacy Policy URL registered with Apple + Google |
| `terms/index.html` | Terms / EULA URL referenced by App Store listing |
| `support/index.html` | Support URL registered with both stores |
| `delete-account/index.html` | Account-deletion URL required by Google Play |
| `googlea544ab84e7293dcb.html` | Search Console verification |
| `CNAME` | Custom domain |
| `styles.css`, `script.js` | Shared by the protected pages; editing them would force a cache-buster bump inside the protected HTML |
| `i/og-tickster.png`, `i/tickster-icon*.png`, `i/google-play-mask.png` | Tickster assets |

**Enforcement:** before Phase 1, record a SHA-256 baseline of every protected
file. After every phase, re-hash and diff. Any change = stop and revert.

```bash
# baseline (run once, before Phase 1)
shasum -a 256 privacy/index.html terms/index.html support/index.html \
  delete-account/index.html googlea544ab84e7293dcb.html CNAME styles.css script.js \
  i/og-tickster.png i/tickster-icon.png i/tickster-icon-128.png i/google-play-mask.png \
  > /tmp/leximagine-protected.sha256

# check (after every phase) — must print OK for every line
shasum -a 256 -c /tmp/leximagine-protected.sha256
```

The only Tickster file that changes is **`index.html`, header block only**
(Option 1, approved 2026-10-16).

---

## 1. Target structure

```
leximagine.com/
├── index.html              ← Tickster home. ONLY change: supertab strip in <header>
│                             + one extra <link> to supertabs.css
├── privacy/ terms/ support/ delete-account/   ← PROTECTED, untouched
├── supertabs.css           ← NEW. Supertab strip styles only
└── immersive/
    ├── index.html          ← NEW. Single page, anchor tabs
    ├── immersive.css       ← NEW. Page-specific styles
    └── media/              ← NEW. Poster images + OG image
```

Why new CSS files instead of editing `styles.css`: the protected pages load
`styles.css`. Adding rules there is harmless, but shipping it means bumping its
`?v=` cache-buster — which lives *inside the protected HTML*. New files avoid
that entirely.

`immersive/index.html` still loads `../styles.css` (read-only reuse of Syne,
cards, FAQ accordion, nav, palette) plus its own `immersive.css`, and reuses
`../script.js` unchanged — its scroll-spy and mobile menu already work on any
page whose nav links are `#anchors`.

---

## 2. Supertab strip

| | Supertab A | Supertab B |
|---|---|---|
| Label | Tickster Pet Scan | Immersive Shopping |
| Link | `/` | `/immersive/` |
| Active on | homepage | immersive page |

- Markup: `<nav class="supertabs" aria-label="Products">` with two links;
  active one carries `aria-current="page"`. Not `.nav-link`, so the existing
  scroll-spy ignores it.
- Desktop: pill pair to the right of the LexImagine wordmark; existing tab row
  moves to a second line under a hairline.
- Mobile: pills stay **outside** the hamburger (always visible, full width,
  50/50). Inner tabs remain in the hamburger. If "Immersive Shopping" doesn't fit
  at 360px, short labels "Tickster" / "Immersive" via a media query.
- Protected pages (`/privacy/` etc.) get **no** strip (Option 1). They reach
  Immersive via Home.

---

## 3. Immersive page — `/immersive/`

**Tabs (anchors):** Overview · About · Portfolio · How it works · FAQ · Contact

| Section | Content |
|---|---|
| `#overview` | Headline + one-liner aimed at merchants, one short demo loop or poster |
| `#about` | Why grid storefronts fall short; who it's for |
| `#portfolio` | One card per product: video (click-to-play) + name + 2–3 line description |
| `#how-it-works` | 3 steps, e.g. connect catalog → generate space → shop |
| `#faq` | Same `<details>` accordion component as Tickster |
| `#contact` | `mailto:` demo-request link — **no form** (a form collects personal data and would need its own privacy policy) |

**No Privacy/Terms tabs.** The existing ones are Tickster-specific and must not be
reused. If Immersive ever collects data (form, app, analytics), it gets its own
`/immersive/privacy/` — never the Tickster one.

**Video:** host on YouTube or Vimeo; embed behind a lightweight poster
("facade") that loads the player only on click. Not self-hosted — GitHub Pages
has a 100 MB file limit and bandwidth caps, and eager players hurt page speed.
Exception: a ≤3 MB muted MP4 loop for the hero is fine to self-host.

---

## 4. SEO / AEO for the new page

- Own `<title>`, meta description, canonical `https://leximagine.com/immersive/`,
  OG/Twitter tags with a **new** OG image (do not reuse `og-tickster.png`).
- JSON-LD `@graph`: `Organization` (same `@id` as the homepage, so engines see
  one company), `WebPage`, `ItemList` of portfolio products, one `VideoObject`
  per video, `FAQPage` (visible text must match byte-for-byte), `BreadcrumbList`.
- `sitemap.xml`: add `/immersive/` (homepage `lastmod` bumps because its header
  changed; protected entries untouched).
- `llms.txt`: add an "Immersive Shopping" section and change the "single-product
  site" line. Tickster facts and URLs stay as they are.
- `robots.txt`: no change.
- During build, the page carries `<meta name="robots" content="noindex">` and
  isn't linked from anywhere. Removed at launch (Phase 4).

---

## 5. Phases — one commit each, independently revertible

| Phase | Work | Touches Tickster? |
|---|---|---|
| **0. Guardrails** | Record protected-file hash baseline | No |
| **1. Skeleton** | `immersive/index.html` + `immersive.css` with placeholder content, `noindex`, unlinked | No |
| **2. Content** | Fill in products, videos, copy, FAQ, contact | No |
| **3. Supertabs** | `supertabs.css` + strip in `index.html` header; strip also on immersive page | `index.html` header only |
| **4. Launch** | Remove `noindex`, add schema, sitemap, llms.txt, OG image; push | No |
| **5. Verify** | Hash check, desktop + 375px screenshots, schema/FAQ parity check, Rich Results Test, GSC request indexing for `/immersive/` | No |

After each phase: run the hash check, and confirm the four store URLs return
200 with unchanged content.

---

## 6. Needed from Ashok before Phase 2

1. Portfolio product list — names + 2–3 line descriptions
2. Video URLs (YouTube/Vimeo) + a poster image per video
3. Contact address for Immersive. `support@leximagine.com` is Tickster's
   registered support address; recommend a separate one, e.g.
   `hello@leximagine.com`
4. Headline / one-liner for `#overview` (I can draft)
5. FAQ questions (I can draft from the product descriptions)

## 6a. Answers received 2026-10-16

| # | Product | Site | Notes |
|---|---|---|---|
| A | chummaNaachy: MAHKIT PLAYS | — | Parody; nothing is for sale. Outputs shareable to Instagram / social; TikTok videos to follow |
| B | Sundaram Pottery | https://www.sundarampottery.com (200 OK) | Traditional selling site transformed into immersive shopping for high-quality pottery |
| C | Backdropsource | https://www.backdropsource.com (200 OK) | Immersive drone browse of a massive expo-centre location |
| D | vaangungo.app | https://vaangungo.app (**no response 2026-10-16**) | Immersive shop linked from Linktree / Instagram, for individuals with a few designer and luxury items to sell. **Pay as you go** |

- Contact: `ashok@leximagine.com`
- Videos + posters: later. Build with poster placeholders.
- Headline + FAQ: Claude drafts, Ashok reviews.

**All four immersive builds are in staging (Ashok, 2026-10-16).** The domains
that resolve (B, C) are the clients' current traditional sites, not the
immersive versions. So: **no outbound links to any product site** for now —
name, description, and video only. Add links per product as each goes live.

Open: exact styling of Product A's name; OK to name B and C publicly;
D's pay-as-you-go pricing (or just say "pay as you go").

## 7. Decisions to flag (not blocking)

- **Homepage copy now contradicts multi-product:** the eyebrow "One focused
  product" and the About line "On LexImagine.com, Tickster is the product" will
  read oddly once a second supertab exists. Not part of this plan (Option 1
  scope) — revisit separately.
- **Homepage `<title>`** stays "LexImagine | Tickster Pet Scan". Fine, since `/`
  remains Tickster's home.
