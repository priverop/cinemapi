# Project Description

Cine aggregator with scraping pipeline, background jobs, and filterable API.

## Database

This is the info we need to gather:

- Movie theater: name, location, discounted days, and prices (regular / discounted fee).
- Movie: name, duration (minutes), genre, days and hours (array of datetimes).
- Showtimes: showtime, theater_id, movie_id. The same movie could be in different theaters.

## User query

The user will search for all the movies that fits these parameters:
- Chosen movie theaters.
- The day he wants to go.
- The hour when he is available.

## Questions for the future

- Movie.genre is a string. Should we make a specific table? To make searches more efficient.

## Data models

### Showtimes

- Date and time are exactly what the website is showing. We don't deal with timezones. If a user is checking other timezone's theaters...