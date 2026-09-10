# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1](https://github.com/fabiocicerchia/chaos-toolbox/compare/v2.0.0...v2.0.1) (2026-09-10)


### Bug Fixes

* **coc:** restore the reporting address and the version deep-link ([#66](https://github.com/fabiocicerchia/chaos-toolbox/issues/66)) ([98efe3a](https://github.com/fabiocicerchia/chaos-toolbox/commit/98efe3ad452b6e9ac7b1099f32b57a3f1c0518bd))

## [2.0.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.4.0...v2.0.0) (2026-09-10)


### ⚠ BREAKING CHANGES

* the command is now `chaosbox`. The image entrypoint, the compose service in examples/, and every `chaos <experiment>` invocation are now `chaosbox`. Prose about chaos experiments is unchanged — only the command was renamed.

### Code Refactoring

* rename the `chaos` command to `chaosbox` ([#59](https://github.com/fabiocicerchia/chaos-toolbox/issues/59)) ([3f74c89](https://github.com/fabiocicerchia/chaos-toolbox/commit/3f74c8986d095658dee6d7c5b3387037f78c35ce))

## [1.4.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.3.0...v1.4.0) (2026-09-10)


### Features

* **packaging:** man page, and an install that stages rather than pulls ([#58](https://github.com/fabiocicerchia/chaos-toolbox/issues/58)) ([b0f285e](https://github.com/fabiocicerchia/chaos-toolbox/commit/b0f285ef8507675e17f1f1153b73674a2917ceb9))


### Bug Fixes

* **release:** grant id-token on the job that calls the signing workflow ([#62](https://github.com/fabiocicerchia/chaos-toolbox/issues/62)) ([9ec1d53](https://github.com/fabiocicerchia/chaos-toolbox/commit/9ec1d537eee5384ae5befe6428336e45f6aa311b))

## [1.3.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.2.2...v1.3.0) (2026-09-08)


### Features

* add the eight-verb repo contract ([#52](https://github.com/fabiocicerchia/chaos-toolbox/issues/52)) ([1d276cf](https://github.com/fabiocicerchia/chaos-toolbox/commit/1d276cf050fde42441d16fcd130400f6593c689b))


### Bug Fixes

* point install docs at an image tag that exists ([#55](https://github.com/fabiocicerchia/chaos-toolbox/issues/55)) ([9b8904f](https://github.com/fabiocicerchia/chaos-toolbox/commit/9b8904f9ab7106ab16ee3e682c771df5e1d11867))

## [1.2.2](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.2.1...v1.2.2) (2026-09-04)

### Bug Fixes

- **ci:** pin the editorconfig-checker binary version ([#43](https://github.com/fabiocicerchia/chaos-toolbox/issues/43)) ([b35c3a6](https://github.com/fabiocicerchia/chaos-toolbox/commit/b35c3a60e56e627f807bbd88383464755573fb4d))

## [1.2.1](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.2.0...v1.2.1) (2026-08-29)

### Bug Fixes

- unblock quality and clear the Scorecard pinned-dependencies finding ([#37](https://github.com/fabiocicerchia/chaos-toolbox/issues/37)) ([1c5b998](https://github.com/fabiocicerchia/chaos-toolbox/commit/1c5b998cc760411c5db77b559828a04303129623))

## [1.2.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.1.0...v1.2.0) (2026-08-25)

### Features

- **docs:** build the docs site in Actions and drop Read the Docs ([#35](https://github.com/fabiocicerchia/chaos-toolbox/issues/35)) ([a688c7e](https://github.com/fabiocicerchia/chaos-toolbox/commit/a688c7e183874a6e9892934e3a44ada56fc3f417))

## [1.1.0](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.2...v1.1.0) (2026-08-24)

### Features

- **net:** scope delay/loss/limit to destination CIDRs ([#26](https://github.com/fabiocicerchia/chaos-toolbox/issues/26)) ([be93b57](https://github.com/fabiocicerchia/chaos-toolbox/commit/be93b5727567ca905fa3edc597aaf5cb98edb3ac))
- **report:** sample latency before and during, and say what changed ([#27](https://github.com/fabiocicerchia/chaos-toolbox/issues/27)) ([f6de533](https://github.com/fabiocicerchia/chaos-toolbox/commit/f6de5338763a675f751c9ac99bc245e3411e05ee))

## [1.0.2](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.1...v1.0.2) (2026-08-13)

### Bug Fixes

- security and code-quality findings ([#23](https://github.com/fabiocicerchia/chaos-toolbox/issues/23)) ([07d7be6](https://github.com/fabiocicerchia/chaos-toolbox/commit/07d7be637b5fd0eb3d25f71321c9f1b6d483e987))

## [1.0.1](https://github.com/fabiocicerchia/chaos-toolbox/compare/v1.0.0...v1.0.1) (2026-08-10)

### Bug Fixes

- publish the image from the release job so it actually runs ([1fa4543](https://github.com/fabiocicerchia/chaos-toolbox/commit/1fa45430901671fae541638a9970d1af7eb5556b))

## 1.0.0 (2026-08-06)

### Features

- **kill:** restart containers and pods, Docker or Kubernetes ([4401768](https://github.com/fabiocicerchia/chaos-toolbox/commit/4401768f8d1e92c855966e350924689212b5b6b4))
- **kill:** restart containers and pods, Docker or Kubernetes ([8a7c14f](https://github.com/fabiocicerchia/chaos-toolbox/commit/8a7c14fa564f4d72361e8cd5c57475202d579e63))

### Bug Fixes

- **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/chaos-toolbox/issues/9)) ([4265bdb](https://github.com/fabiocicerchia/chaos-toolbox/commit/4265bdb2959c0607b7f456a6d32e19703a06d330))
- **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([a95f29b](https://github.com/fabiocicerchia/chaos-toolbox/commit/a95f29bcf1c52638ec46e60efde090ade2e2c3fe))

## [Unreleased]

### Added

- Six experiments — `cpu`, `mem`, `io` (stress-ng) and `delay`, `loss`,
  `limit` (tc/netem) — in one image, each requiring `--duration` and
  tearing its qdisc down on exit.

Not yet released.
