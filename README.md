# Cinemapi

> WIP - Work in progress.

Cinemapi helps movie fans to choose the best local theater!

I was tired of opening multiple tabs to find the right theater any time I wanted to watch a movie. This app aggregates all the theaters and filters them following your preferences.

Built with Rails 8, Turbo, and SQLite.

## Features

- **Backoffice:** theaters and movies management.
- **API:** stateless read of theaters and movies, with filtering.
- **Scrapper:** aggregates movies from a list of local cinema websites.

## Setup

You can either run the project using [VS Code](https://code.visualstudio.com/), and the [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers). Run the project with `bin/dev`.

Or install Ruby (3.4.7), and run `bin/setup`.

## Docs

- [Project description and ideas](/docs/project.md)
- [ADR](/docs/adr.md)