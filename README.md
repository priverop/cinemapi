<div align="center">
  <h1 align="center" style="color: #c0392b; font-size: 3em; letter-spacing: 0.15em;">🎬 CINEMAPI</h1>
</div>

<p align="center"><em>Your local theater aggregator. Filter your favorite theaters by your preferences and decide what to watch at a glance.</em></p>

<p align="center">
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/priverop/cinemapi">
<img alt="CI Status" src="https://github.com/priverop/cinemapi/actions/workflows/ci.yml/badge.svg">
<img alt="Rails" src="https://img.shields.io/badge/rails-8-brightgreen?logo=rubyonrails&logoColor=white">
<img alt="License" src="https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat">
</p>

---

## Features

- **Backoffice:** theaters and movies management.
- **API:** stateless read and search of theaters and movies, with filtering.
- **Scraper:** aggregates movies from the theater websites.

## Setup

Install [Ruby 3.4.7](https://www.ruby-lang.org/en/downloads/), then:

```bash
bin/setup --skip-server # install deps, create and migrate DB
bin/rails db:seed       # load theater data
bin/scraper             # scrape movies from theater websites
bin/dev                 # start the server
```

This project also runs with [Docker](https://www.docker.com/) or [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) (VS Code).

## Docs

- [Project description and ideas](/docs/project.md)
- [Decision Records](/docs/decision-records.md)

## What's next

- Cinesa scraper anti-bot. The current system is not working in production. We should diagnose it, and test for different strategies.
- Add more cinemas.
- Complete movie info (trailer, link to buy ticket, etc).
- Complete the API with all the filters.