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