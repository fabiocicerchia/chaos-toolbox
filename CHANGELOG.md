# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Six experiments — `cpu`, `mem`, `io` (stress-ng) and `delay`, `loss`,
  `limit` (tc/netem) — in one image, each requiring `--duration` and
  tearing its qdisc down on exit.

Not yet released.
