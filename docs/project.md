# Project Description

This project has two parts: Scrap & populating the database, and serving endpoints to get the data.

## Database

This is the info we need to gather:

- Movie theater: name, location, spectator days (SD), and prices (regular fee / SD fee).
- Movie: name, duration (minutes), genre, days and hours (array of datetimes).

## User query

The user will search for:

- The movie theaters he has close by.
- The day he wants to go.
- The hour when he is available.

## Future ideas

- Max price he wants to pay.
- User preferences. Store the query?
- Ending hour (limiting time): hour + duration should not reach the specified ending hour.