# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.2.0...v1.2.1) (2026-08-29)


### Bug Fixes

* unblock quality and clear the Scorecard pinned-dependencies finding ([#37](https://github.com/fabiocicerchia/chaos-toolbox/issues/37)) ([1c5b998](https://github.com/fabiocicerchia/chaos-toolbox/commit/1c5b998cc760411c5db77b559828a04303129623))

## [1.2.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.1.0...v1.2.0) (2026-08-25)


### Features

* **docs:** build the docs site in Actions and drop Read the Docs ([#35](https://github.com/fabiocicerchia/chaos-toolbox/issues/35)) ([a688c7e](https://github.com/fabiocicerchia/chaos-toolbox/commit/a688c7e183874a6e9892934e3a44ada56fc3f417))

## [1.1.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.2...v1.1.0) (2026-08-24)


### Features

* **net:** scope delay/loss/limit to destination CIDRs ([#26](https://github.com/fabiocicerchia/chaos-toolbox/issues/26)) ([be93b57](https://github.com/fabiocicerchia/chaos-toolbox/commit/be93b5727567ca905fa3edc597aaf5cb98edb3ac))
* **report:** sample latency before and during, and say what changed ([#27](https://github.com/fabiocicerchia/chaos-toolbox/issues/27)) ([f6de533](https://github.com/fabiocicerchia/chaos-toolbox/commit/f6de5338763a675f751c9ac99bc245e3411e05ee))

## [1.0.2](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.1...v1.0.2) (2026-08-13)


### Bug Fixes

* security and code-quality findings ([#23](https://github.com/fabiocicerchia/chaos-toolbox/issues/23)) ([07d7be6](https://github.com/fabiocicerchia/chaos-toolbox/commit/07d7be637b5fd0eb3d25f71321c9f1b6d483e987))

## [1.0.1](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.0...v1.0.1) (2026-08-10)


### Bug Fixes

* publish the image from the release job so it actually runs ([1fa4543](https://github.com/fabiocicerchia/chaos-toolbox/commit/1fa45430901671fae541638a9970d1af7eb5556b))

## 1.0.0 (2026-08-06)


### Features

* **kill:** restart containers and pods, Docker or Kubernetes ([4401768](https://github.com/fabiocicerchia/chaos-toolbox/commit/4401768f8d1e92c855966e350924689212b5b6b4))
* **kill:** restart containers and pods, Docker or Kubernetes ([8a7c14f](https://github.com/fabiocicerchia/chaos-toolbox/commit/8a7c14fa564f4d72361e8cd5c57475202d579e63))


### Bug Fixes

* **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/chaos-toolbox/issues/9)) ([4265bdb](https://github.com/fabiocicerchia/chaos-toolbox/commit/4265bdb2959c0607b7f456a6d32e19703a06d330))
* **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([a95f29b](https://github.com/fabiocicerchia/chaos-toolbox/commit/a95f29bcf1c52638ec46e60efde090ade2e2c3fe))

## [Unreleased]

### Added

- Six experiments — `cpu`, `mem`, `io` (stress-ng) and `delay`, `loss`,
  `limit` (tc/netem) — in one image, each requiring `--duration` and
  tearing its qdisc down on exit.

Not yet released.
