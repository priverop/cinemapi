# Project Description

This project has two parts: Scrap & populating the database, and serving endpoints to get the data.

## Database

This is the info we need to gather:

- Movie theater: name, location, discounted days, and prices (regular / discounted fee).
- Movie: name, duration (minutes), genre, days and hours (array of datetimes).
- Showtimes: showtime, theater_id, movie_id. The same movie could be in different theaters.

## User query

The user will search for:

- The movie theaters he has close by.
- The day he wants to go.
- The hour when he is available.

## Future ideas

- Max price he wants to pay.
- User preferences. Store the query?
- Ending hour (limiting time): hour + duration should not reach the specified ending hour.

## Questions for the future

- Movie.genre is a string. Should we make a specific table? To make searches more efficient.
