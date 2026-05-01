# Decisions Record

## Data model

### Arrays as String

Instead of creating several tables to store genres, directors, etc; I'd rather serialize arrays as JSON strings for the sake of the MVP.

It's true that, whenever the user wants to filter by genre (very possible), we'll need a separated table for performance. Or maybe PostgreSQL jsonbin is enough?

## Scraper

### Cinesa 7 days scraping

Cinesa sometimes have movie promotions, where they offer a certain movie for the next couple of MONTHS. Meaning that we could be scraping days with only a single movie. This is why I only scrap the next seven days.

### Cinesa Cloudflare

It looks like Cinesa is behind a Cloudflare anti-scrap wall, which is easy to bypass by just changing your user-agent.

### Languages

Cinesa has `original language` movies and `dubbed` movies, but they have no tag for it. We cannot distinguish them at the moment. However, in their attributes they have Vose, Vosi (original audio + english subtitles), CATALAN, Es Nuestro Cine (local Spanish production program). We use the `Es Nuestro Cine` for the `:vo` language label.

Renoir has many possibilities, right now we only track two (vose, and vo), we'll have to keep an eye on it.