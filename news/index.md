# Changelog

## ntfy 0.1.0

CRAN release: 2025-10-26

- CRAN release
- [`ntfy_send()`](https://jonocarroll.github.io/ntfy/reference/ntfy_send.md)
  returns invisibly
  ([\#22](https://github.com/jonocarroll/ntfy/issues/22),
  [@hadley](https://github.com/hadley))
- removed messaging on attach when no topic is set
  ([\#23](https://github.com/jonocarroll/ntfy/issues/23),
  [@hadley](https://github.com/hadley))
- more robust request
  ([\#24](https://github.com/jonocarroll/ntfy/issues/24),
  [@hadley](https://github.com/hadley)) and tests
  ([\#25](https://github.com/jonocarroll/ntfy/issues/25),
  [@hadley](https://github.com/hadley))
- renamed default branch to main

## ntfy 0.0.6

CRAN release: 2024-11-06

- CRAN release - minor internal changes

## ntfy 0.0.5

- Refactored to use {httr2} with tests, simplified image sending,
  improved/fixed NDJSON parsing, and general clean-up
  ([\#15](https://github.com/jonocarroll/ntfy/issues/15),
  [@andrewheiss](https://github.com/andrewheiss))

## ntfy 0.0.4

- Added basic authentication for protected servers
  ([\#12](https://github.com/jonocarroll/ntfy/issues/12),
  [@andrewheiss](https://github.com/andrewheiss))

## ntfy 0.0.3

- Added inline images including ggplot2
- Trim trailing slash from server URL

## ntfy 0.0.2

- Added
  [`show_emoji()`](https://jonocarroll.github.io/ntfy/reference/show_emoji.md)
  and processed emoji/tag data
- Added a `NEWS.md` file to track changes to the package.

## ntfy 0.0.1

- Initial working package
