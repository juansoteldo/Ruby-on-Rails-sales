# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.23] - 2021-07-31
### Fixed
- fix salesperson_email creation bug

## [2.0.22] - 2021-07-27
### Added
- transfer sales person email to campaign manager in user custom field

## [2.0.21] - 2021-07-23
### Fixed
- fix NameError in cm#update_subscriptions

## [2.0.20] - 2021-07-22
### Changed
- split quote_url to 3 parts

## [2.0.19] - 2021-07-21
### Fixed
- fixed MarketingEmail class validations

## [2.0.18] - 2021-07-20
### Changed
- Move CM webhooks from user to request model

## [2.0.17] - 2021-07-05
### Added
- Quote url method for a Request

## [2.0.16] - 2021-06-28
### Added
- Custom unsubscribe page

## [2.0.15] - 2021-06-23
### Added
- Proper Honeybadger API key

## [2.0.14] - 2021-06-22
### Added
- Handling CM webhooks for REsubbing users

## [2.0.13] - 2021-06-21
### Added
- Handling CM webhooks for unsubbing users

## [2.0.12] - 2021-06-17
### Added
- Back-syncing suppressions list with CM and DB

## [2.0.11] - 2021-06-16
### Added
- Export user data to two separate CM lists

## [2.0.10] - 2021-06-07
### Added
- Export user data to CM for staging env

## [2.0.9] - 2021-06-02
### Added
- Move CampaignMonitor logic to cm library

## [2.0.8] - 2021-06-02
### Added
- User ID and token to the user CampaignManager exported data

## [2.0.7] - 2021-05-31
### Added
- Sync between users and CampaignManager Active/Inactive lists

## [2.0.6] - 2021-05-28
### Added
- Purchased flag in the CampaignManager lists

## [2.0.5] - 2021-05-28
### Added
- Enhance boolean responces in exported custom user data

## [2.0.4] - 2021-05-26
### Added
- Export of custom user data to CampaignManager

## [2.0.3] - 2021-05-24
### Added
- Rake task for exporting emails to CampaignManager

## [2.0.2] - 2021-05-18
### Added
- MostlyGmail::Base.refresh_credentials! for refreshing tokens
- New API client_id and secret for sales account

## [2.0.1] - 2020-11-02

### Added
- Allow active salespeople to toggle auto-quoting