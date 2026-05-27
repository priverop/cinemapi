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

### Timezone

The current scope of this project is Spain from Península (CET), we don't support other timezones. This means that the times you see in Cinemapi are the times the scraper saw at the websites. No conversions.

### Duplicated showtimes with different languages

Some theaters such as `Zoco Majadahonda` has different movie pages / entries for the same movie, just changing the language. This could be an issue if both movies are playing at the same time (same theater_id, movie_id, and showtime). The importer will skip the second showtime entirely, even if the language is different.

### ABC Risk in UI / JSON

We could scrap the  `<script>addToJSON('s', {...})</script>` JSON blob with `Fecha`, `Hora`, `Formato` fields, the data source the frontend itself uses to render the tabs.

We are scraping the UI, but if it breaks, we'll switch to JSON parsing.

### Maldà: skipping lines without a language tag

Every real film line in Maldà's schedule is tagged `(VOE)` or `(VOSE)`. Other lines — hall rentals (`LLOGUER DE SALA "EL KALAM"`), concerts, events — have no such tag. We skip them.

### Maldà: movies with no movie page

There are movies in the showtime page, with no movie page. Importing fails:

```
[Scraper] [malda] [Cinema Maldà] [CONOCE A LOS BÁRBAROS] [PostFinder] GET https://www.cinemamalda.com/wp-json/wp/v2/posts?search=CONOCE+A+LOS+B%C3%81RBAROS&_fields=slug%2Ctitle&per_page=1.
[Scraper] [malda] [Cinema Maldà] [CONOCE A LOS BÁRBAROS] [Normalizer] Normalizing 1 movies.
[Scraper] [malda] [Cinema Maldà] [CONOCE A LOS BÁRBAROS] [Importer] Importing 1 movies.
[Scraper] [malda] [Cinema Maldà] [CONOCE A LOS BÁRBAROS] [Importer] Import failed for 'CONOCE A LOS BÁRBAROS': Validation failed: Duration can't be blank.
```

Maybe in the future we can fix this