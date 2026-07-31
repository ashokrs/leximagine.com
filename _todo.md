# leximagine.com — open items

Working notes for the Tickster Pet Scan site. Not published: the leading
underscore makes Jekyll (which GitHub Pages runs on this repo) skip the file,
so it is not reachable at leximagine.com/_todo.md.

Last updated: 2026-07-30

---

## Status

| | |
|---|---|
| **Apple App Store** | LIVE — https://apps.apple.com/app/tickster-pet-scan/id6760481917 |
| **Google Play** | LIVE — https://play.google.com/store/apps/details?id=com.powerwand.mobile |

Both stores live as of 2026-07-31. All six store links on the site are wired to
the real listings; nothing points at `#faq` any more.

---

## 1. Launch wiring  ← DONE 2026-07-31

- [x] **`index.html` — all 6 store links** (hero, hero panel, download CTA ×
      Apple/Play) point at the real store URLs, each with
      `target="_blank" rel="noopener"` and a clean aria-label.
- [x] **`index.html` — FAQ Q1** now states both stores are live, changed in both
      the visible `<details>` answer and the `FAQPage` JSON-LD. Verified 8/8
      matching.
- [x] **`index.html` — MobileApplication JSON-LD.** `installUrl` and `downloadUrl`
      are arrays holding both store URLs.
- [x] **`llms.txt`** — Availability bullet, download FAQ answer, and Citation note
      all updated to "live on both stores as of 2026-07-31".
- [x] **`sitemap.xml`** — homepage `lastmod` → 2026-07-31.

---

## 2. Open decisions

- [x] ~~**Subscription prices missing from the schema.**~~ DONE 2026-07-30.
      `offers` added to the `MobileApplication` JSON-LD as two `Offer` objects:
      Monthly US$9.99 and Annual US$59.99, `category: subscription`.
      The prices were also added to FAQ Q7 ("What Tickster subscription plans are
      available?") — in **both** the visible answer and the `FAQPage` JSON-LD —
      because Google requires structured data to reflect content visible on the
      page. Wording is scoped to the US and notes that other regions are set by
      the store, since Apple/Google price per storefront.
      Rich Results Test should now flag only `aggregateRating`.
- [x] ~~**`operatingSystem` says `"iOS, Android"` while only iOS is live.**~~
      Resolved 2026-07-31 — both stores are live, so `"iOS, Android"` is now
      simply accurate. No change was needed.
- [ ] **`aggregateRating`** — the only remaining Rich Results warning. Needs the
      real App Store average and rating **count** (e.g. 5.0 from 3 ratings).
      Two conditions before adding it:
      1. Google expects the rating to be **visible on the page**, and the site
         currently displays no ratings anywhere. Adding the markup alone
         recreates the visible-vs-markup mismatch that the pricing work fixed.
         So a small "★ 5.0 on the App Store" element has to go on the page too.
      2. Ratings move. A hardcoded `ratingCount` goes stale fast at low volume,
         and stale rating markup is worse than none. Revisit once the count is
         stable enough to be worth maintaining.
      Never invent the figures — fabricated ratings earn a manual action.

---

## 3. Search / answer engines

- [x] `sitemap.xml` submitted to Google Search Console (Domain property,
      processed successfully, 5 pages discovered)
- [ ] **Bing Webmaster Tools** — bing.com/webmasters → "Import from Google Search
      Console". Matters more than usual: ChatGPT's web search is Bing-backed,
      so it is a direct AEO channel.
- [ ] **Check GSC → Indexing → Pages in ~1 week.** Want the indexed count climbing
      toward 5. `/` and `/privacy/` were indexed first; `/terms/` and `/support/`
      had indexing requested. "Crawled – currently not indexed" is normal early
      on; only worth investigating if a page sticks there past a couple of weeks.

---

## 4. Verification after any of the above

```bash
# FAQ visible text must match the FAQPage schema exactly
python3 - <<'PY'
import re, json, html
norm=lambda s: re.sub(r'\s+',' ',html.unescape(s)).strip()
s=open('index.html').read()
g=json.loads(re.search(r'<script type="application/ld\+json">(.*?)</script>', s, re.S).group(1))
faq=[n for n in g['@graph'] if n['@type']=='FAQPage'][0]
sch=[(x['name'],x['acceptedAnswer']['text']) for x in faq['mainEntity']]
sec=re.search(r'<section id="faq".*?</section>', s, re.S).group(0)
vis=[(norm(q),norm(a)) for q,a in re.findall(
    r'<summary>\s*<span>(.*?)</span>.*?<div class="faq-answer">\s*<p>(.*?)</p>', sec, re.S)]
bad=[i for i,((a,b),(c,d)) in enumerate(zip(vis,sch),1) if a!=c or b!=d]
print(f"{len(vis)} visible / {len(sch)} schema, mismatches: {bad or 'none'}")
PY

# every canonical must be a direct 200, no redirect
for p in / /support/ /privacy/ /terms/ /delete-account/; do
  curl -s -o /dev/null -w "$p %{http_code} redirects=%{num_redirects}\n" "https://leximagine.com$p"
done
```

**Bump the cache-buster** (`?v=...` on `styles.css` / `script.js`, in all 5 HTML
files) whenever either of those files changes, or returning visitors keep the
stale copy.

**Never touch** `googlea544ab84e7293dcb.html` — it is the Google Search Console
verification file. If its filename or contents change, verification is revoked.
