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
| **Google Play** | Resubmitted, in review as of 2026-07-30 |

Site is fully wired for Apple. All three Google Play links deliberately still
point at `#faq`, which explains the in-review status.

---

## 1. When Google Play is approved  ← main task

Play URL will be: `https://play.google.com/store/apps/details?id=<package-name>`

- [ ] **`index.html` — 3 Google Play links.** Find the 3 `<a class="mini-store-link">`
      with `href="#faq"` (hero, hero panel, download CTA). For each:
      - `href` → the Play URL
      - add `target="_blank" rel="noopener"`
      - `aria-label` → `Download Tickster Pet Scan on Google Play`
        (drop the `— see FAQ for availability` suffix)
- [ ] **`index.html` — FAQ Q1** ("Where can I download Tickster Pet Scan?").
      Remove the "Android version is still in review" sentence.
      **Must be changed in BOTH places, byte-for-byte identical:**
      1. the visible `<details>` answer inside `<section id="faq">`
      2. the `FAQPage` JSON-LD `acceptedAnswer.text` in the `<head>`
      Google penalises FAQ schema that does not match the visible text.
- [ ] **`index.html` — MobileApplication JSON-LD.** `installUrl` and `downloadUrl`
      currently hold only the Apple URL. Decide whether to list both stores or
      keep Apple as primary.
- [ ] **`llms.txt`** — update three places: the `**Availability:**` bullet, the
      "Where can I download" FAQ answer, and the dated caveat in `## Citation`.
- [ ] **`sitemap.xml`** — bump `<lastmod>` on the homepage entry.

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
- [ ] **`operatingSystem` says `"iOS, Android"`** while only iOS is live. Either
      leave it (Android is imminent) or narrow to `"iOS"` until Play clears.
- [ ] **`aggregateRating`** — only add once real ratings exist. Fabricated ratings
      earn a structured-data manual action.

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
