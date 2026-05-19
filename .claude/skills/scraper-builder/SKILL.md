---
name: scraper-builder
description: Guides the creation of a new web scraper for lib/scraper/ in the cinemapi Rails project. Follows TDD, reuses existing components when possible, and asks before every non-trivial decision. Use this skill whenever the user says "create a new scraper", "add a scraper", "build a scraper", "new theater scraper", or invokes /scraper-builder. Also trigger when the user mentions wanting to scrape a new cinema website, add a new theater with automatic data, or integrate a new cinema chain.
---

# Scraper Builder

You are helping add a new web scraper to the cinemapi Rails project. The scraper pipeline lives in `lib/scraper/` and follows established conventions. You will guide this process step by step, **asking before every non-trivial decision**.

The two existing scrapers are your reference implementations:

- **Renoir**: HTML/Nokogiri, `Scraper::Client` for HTTP, instance `Normalizer` (date injected at init because date comes from URL params)
- **Cinesa**: JSON API + JWT auth, custom `AuthClient`/`ApiClient`, class-method `Normalizer` (date embedded in JSON data)

---

## Step 1 — Read the codebase

Read all files under `lib/scraper/` and `spec/lib/scraper/`. Also read:

- `lib/scraper.rb` (module, SOURCES hash, error classes)
- `app/models/theater.rb` (scraper_key enum)

Do not skip this step. You need full context before asking the user anything.

---

## Step 2 — Gather user input

Ask the user for:

1. The website URL to scrape
2. What type of scraping is needed (HTML page, JSON API, API with auth, other)
3. Any research they've already done (page structure, endpoints found, auth mechanism, etc.)

---

## Step 3 — Confirm understanding

Restate what the user told you in 2-3 sentences. Ask clarifying questions if anything is ambiguous. Do not proceed until you have a clear picture of the target website's structure.

---

## Step 4 — Reuse analysis

Can an existing scraper (Renoir or Cinesa) handle this new theater **with zero changes**?

The reuse bar is strict: reuse only if the existing scraper works 100% as-is — no new conditionals, no new branches, no new parameters. URL differences are fine (URL comes from the Theater record). Structure differences are not.

Show your analysis, state your conclusion, and ask the user to confirm.

**If reuse confirmed → Step 4a, then stop.**
**If new scraper needed → Step 5.**

### Step 4a — Reuse path

Decide whether new tests or fixtures are needed to cover the reused scraper with this new theater. Explain your reasoning. Add them if needed. Then tell the user: add the theater to `db/seeds.rb` and run `bin/scraper` manually to verify. Skill ends here.

---

## Step 5 — Generic component analysis

Two components are shared across all scrapers (never recreate them):

- `Scraper::Client` — plain HTTP fetch; use when no auth is needed
- `Scraper::Importer` — DB upsert; always reused

If the target site requires authentication or a custom API client, new classes are needed following the Cinesa `AuthClient`/`ApiClient` pattern. Present your analysis, explain what's needed and why, and ask the user to confirm.

---

## Step 6 — Parser/Normalizer reuse

Can any existing `CalendarParser`, `MovieParser`, or `Normalizer` be reused? This is rare but check explicitly. Same strict rule: 100% compatible, no additions. Show your analysis and ask.

---

## Step 7 — Key name

Ask the user for the snake_case key name for this scraper (e.g. `amore`, `golem`). This becomes the enum value, Ruby module name, and folder name.

---

## Step 8 — Add enum key to Theater model

Edit `app/models/theater.rb` to add the new key to the `scraper_key` enum with the next integer value. **No migration needed** — the column is already an integer, only the model file needs updating.

Current enum pattern: `enum :scraper_key, manual: 0, renoir: 1, cinesa: 2`
Add the new key with the next integer.

---

## Step 9 — Register in Scraper::SOURCES

Edit `lib/scraper.rb` to add the new orchestrator to the `SOURCES` hash. Without this, `Scraper.run_all` will never invoke the new scraper.

```ruby
SOURCES = {
  "renoir" => "Scraper::Renoir::Orchestrator",
  "cinesa" => "Scraper::Cinesa::Orchestrator",
  "<key>"  => "Scraper::<Module>::Orchestrator"
}.freeze
```

---

## Step 10 — Create folder structure

Create the directories:

- `lib/scraper/<key>/`
- `spec/lib/scraper/<key>/`

---

## Step 11 — Fixtures

Fixture type depends on scraper kind:

- **HTML scraper** → real HTML page saved as `spec/fixtures/<key>/<theater>.html`
- **JSON/API scraper** → real JSON responses as `spec/fixtures/<key>/<endpoint>.json`; VCR cassettes for HTTP calls in specs

Ask the user to provide fixture content, or fetch it directly if the URL is publicly accessible.

---

## Step 12 — Write tests first (TDD)

Write specs for every new class before writing any implementation. Follow the structure of the existing spec closest to the new scraper type:

- HTML → follow `spec/lib/scraper/renoir/`
- JSON API → follow `spec/lib/scraper/cinesa/`

**Every class must have a spec.** Orchestrator specs mock all collaborators (see existing orchestrator specs). Parser/Normalizer specs use fixtures directly.

---

## Step 13 — Implement the classes

### Language mapping

Investigate the raw data before asking the user anything. For API scrapers, check all available endpoints and response fields — language info may appear as a label or tag separate from the main showtime data (e.g., Cinesa's "Es Nuestro Cine" tag, found in a different attribute). For HTML scrapers, inspect the fixture for any language markers.

Present your findings to the user: what labels the site uses and how you propose to map them to `:vo`, `:vose`, `:dubbed`. Only ask the user to decide if the mapping is genuinely ambiguous (e.g., the site has no tag that distinguishes `:vo` from `:dubbed`).

Once agreed, document the conclusion in `docs/languages.md` following the existing format (one bullet per theater).

**Rule: `normalize_language` must never return nil.** If the language string is blank, nil, or does not match any known pattern, raise `Scraper::UnknownLanguageError`. Returning nil would pass nil language to the Importer, which stores NULL in the DB. Fail loudly instead.

### Implementation

Write the new scraper classes following the existing scraper most structurally similar to the new one:

- **HTML site** → Nokogiri, `CSS_SELECTORS` constant
- **JSON API** → `JSON.parse`

If a structural difference doesn't fit either pattern cleanly, stop and describe the difference to the user. Ask what to do.

---

## Step 14 — Make tests pass

```bash
bundle exec rspec spec/lib/scraper/<key>/
```

Fix failures by fixing the implementation. Do not modify tests to make them pass.

---

## Step 15 — Check for regressions

```bash
bundle exec rspec spec/lib/scraper/
```

If any existing scraper tests broke, show the failures to the user and ask: should you fix them, or will the user handle it?

---

## Step 16 — Rubocop

```bash
bin/rubocop
```

Fix every offense, not just ones from the new files.

---

## Step 17 — Scalability suggestions

Review the new code alongside the existing scrapers and offer improvement ideas. Good candidates:

- **Orchestrator superclass**: both existing orchestrators share identical structure (days_ok/days_failed counters, per-day rescue loop, logger tags). A base class would eliminate duplication. Now that there are three, the pattern is even more compelling.
- **Normalizer pattern consistency**: Renoir uses instance methods, Cinesa uses class methods. Is it worth standardizing now that there are three scrapers?
- Any other symmetry opportunities you notice.

Present suggestions. Do not implement unless the user asks.

---

## Rules (active throughout every step)

- **Ask before every decision.** Need a new Client class? Ask and explain why. Think two classes could merge? Ask first.
- **One Importer.** Never create a new one. If the Importer needs to handle new fields or edge cases, add them there.
- **Every class must have a spec.**
- **No conditionals added to existing scrapers** to support the new theater — the reuse bar is strict.
- **All user-facing logger messages must end with a period** (project convention in `CLAUDE.md`).
- **Use `.dig`** when accessing nested arrays or hashes.
- **`normalize_language` must raise `Scraper::UnknownLanguageError`** for nil, blank, or unrecognized input — never return nil.

---

## Output format

At each step: state what you found or decided in 1-2 sentences, then ask the one relevant question before proceeding. Do not batch multiple decisions into a single question.
