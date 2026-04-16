# Cinemapi

> WIP - Work in progress.

Cinemapi helps movie fans to choose the best local theater!

I was tired of opening multiple tabs to find the right theater any time I wanted to watch a movie. This app aggregates all the theaters and filters them following your preferences.

Built with Rails 8, Turbo, and SQLite.

## Features

- **Backoffice:** theaters and movies management.
- **API:** stateless read of theaters and movies, with filtering.
- **Scrapper:** aggregates movies from a list of local cinema websites.

## Requirements

This project runs with [Dev Containers](https://guides.rubyonrails.org/getting_started_with_devcontainer.html). Install [VS Code](https://code.visualstudio.com/), and the [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

## Setup

You can either run the project using [VS Code](https://code.visualstudio.com/), and the [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers). Run the project with `bin/dev`.

Or install Ruby, and run `bin/setup`.

## Docs

- [Project description and ideas](/docs/project.md)
- [ADR](/docs/adr.md)