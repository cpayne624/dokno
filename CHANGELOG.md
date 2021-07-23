# Changelog
All notable changes to this project are documented here.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 1.4.5
### Fixed
- Security vulnerability gem updates
  - [CCVE-2021-32740](https://github.com/advisories/GHSA-jxhc-q857-3j6g)

## 1.4.4
### Fixed
- Security vulnerability gem updates
  - [CCVE-2019-16770](https://github.com/puma/puma/security/advisories/GHSA-7xx3-m584-x994)

## 1.4.3
### Fixed
- Security vulnerability gem updates
  - [CVE-2021-22902](https://github.com/advisories/GHSA-g8ww-46x2-2p65)

## 1.4.1
### Fixed
- Security vulnerability gem updates
  - [CVE-2021-22880](https://github.com/advisories/GHSA-8hc4-xxm3-5ppp)
  - [CVE-2021-22881](https://github.com/advisories/GHSA-8877-prq4-9xfw)
  - [GHSA-vr8q-g5c7-m54m](https://github.com/advisories/GHSA-vr8q-g5c7-m54m)

## 1.4.0
### Added
- `dokno-link` class to the `dokno_article_link` helper markup to facilitate link styling by the host
- The ability to quickly return to the prior index page location when viewing an article
- Caching of the category option list within the Category form

### Changed
- Various code re-org

### Fixed
- Problem when the host app has an improperly configured `app_user_object` setting raising a `nil` error during initialization

## 1.3.0
### Added
- Up for review articles
- Starred articles

## 1.2.1
### Fixed
- Problem with invalidating the category option cache when no category is yet in the database

## 1.2.0
### Added
- Search hotkey
- Category context to article pages
- Article counts to category options list
- Capybara tests

## 1.1.1
### Added
- Caching category hierarchy SELECT list OPTIONs

### Changed
- Increased font weight in flyout articles
- Removed extraneous metadata from printed articles
- Improved Faker seed data

### Fixed
- Search results count showed records on page instead of total results
- Changing page number via input caused loss of category context

## 1.1.0
### Added
- Ability to delete categories
- User action flash status messages
- Ability to close flyout articles by clicking outside of them
- Clickable breadcrumbs to the top of article pages
- Breadcrumbs to the top of category index pages when the category has 1+ parent

### Changed
- Stripping all surrounding whitespace from `dokno_article_link` helper
- Improved category hierarchy dropdown appearance
- Auto-focusing on first field on all forms

## 1.0.0
Public API. Usable release :tada:

### Added
- 100% spec coverage
- Search term highlighting on article index pages, detail pages, and print views
- Article permalink support
- Article view count tracking
- Article change logging
- Article index page pagination
- Article index page sorting by title, views, and dates created or updated

### Changed
- README

## 0.1.0
### Added
- Baseline
