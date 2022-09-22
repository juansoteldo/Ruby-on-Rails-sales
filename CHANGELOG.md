# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Unreleased
### Added
- Display error backtrace in retry payload in web UI

## [2.10.2] - 2022-09-21
### Fixed
- Reset job_status after subsequent resets from same user

## [2.10.1] - 2022-09-20
### Fixed
- New shopify orders referncing wrong requests

## [2.10.0] - 2022-09-20
### Added
- Shopify page for adding missed orders

## [2.9.0] - 2022-09-19
### Added
- Deposit redirect url

## [2.8.0] - 2022-09-17
### Added
- faker gem (generates random data for testing)
- minitest-reporters gem (displays a progress bar when running rake test)
- Streak pipeline for test environment
- Gmail label for test environment
### Changed
- Moved most of existing rails credentials into .ENV (better practice to solely use ENV variables instead)
- When updating a user in Campaign Monitor fails (not in list), it will try to add the user to the list instead
- When a CM service request is not successful, only raise the exception if the response code is 404
### Fixed
- Broken unit tests
### Removed
- Fallback for ENV.fetch so it raises an exception instead if a value is not provided

## [2.7.1] - 2022-09-09
### Added
- Sync user data with Campaign Monitor when Shopify order is updated
### Changed
- Refactor environment variables for easier configuration
### Removed
- Unused code for opt_in_email

## [2.7.0] - 2022-09-08
### Added
- Campaign Monitor page for ability to edit smart ids

## [2.6.2] - 2022-09-07
### Fixed
- Issue where SalesUpdater crashes if there is an order in Shopify with no customer

## [2.6.1] - 2022-09-01
### Fixed
- Issue where custom field 'Purchased' does not get updated to 'Yes' after a deposit is made

## [2.6.0] - 2022-08-23
### Added
- Unit tests for phone number validation
- Sync phone number with Campaign Monitor
### Fixed
- Regex validation for phone numbers

## [2.5.1] - 2022-08-22
### Changed
- Updated smart_email_id for production

## [2.5.0] - 2022-08-17
### Added
- Auto quote with CM integration using transactional emails
- Error handling for adding followers to streak boxes
- Error handling for campaign monitor jobs
- Unit testing for campaign monitor jobs
### Changed
- Update auto quote emails with new descriptions
- Refactor code for campaign monitor services
### Fixed
- Issue where box would get stuck in leads after auto quote
- Issue where box would get stuck in leads if a customer submits multiple requests

## [2.4.2] - 2022-08-06
### Added
- Environment variable for SMTP address
- Toggle to enable/disable campaign monitor integration
- Toggle to enable/disable confirmation emails
### Changed
- Improve labeling system for Gmail API to support development/test/staging
- Add request ID to subject line for transactional emails
- Use same regex validation used on WWW for phone number
### Fixed
- Error when attempting to generate new credentials for Google authentication
- Handle edge case when creating streak boxes while sales_manager is nil
- Handle edge case if user does not exist in CM list but does exist in API database
- Issue where requests would get stuck in fresh if a user submits multiple design requests

## [2.4.1] - 2022-07-28
### Added
- Automatic database migration after deployment

## [2.4.0] - 2022-07-27
### Added
- Variant price custom field for Campaign Monitor
- Configure gmail labels for development/staging
- Configure SMTP for development/staging
### Fixed
- Logic error for DISABLE_AUTO_QUOTE_EMAILS

## [2.3.2] - 2022-07-27
### Added
- Toggle for auto quote emails via ENV["DISABLE_AUTO_QUOTE_EMAILS"]

## [2.3.1] - 2022-07-26
### Fixed
- Created requests failing to commit
- Recent scope for requests in development

## [2.3.0] - 2022-07-25
### Added
- Newsletter route for marketing_opt_in
- Awesome_print for pretty printing
### Changed
- Improve performance for CM integration
### Fixed
- Update quote_url in CM after auto-quote
### Removed
- Phone_number column from requests table

## [2.2.0] - 2022-07-18
### Added
- Phone number field

## [2.1.0] - 2022-07-14
### Added
- Debug support for IDE
- Sidekiq support for development environment
- Streak support for development environment
- Sync job state on CRM with user model on API
- Sync custom field job_status with Campaign Monitor
- TLS Support for Redis 6

## [2.0.31] - 2021-12-16
### Added
- Disable marketing emails because company wants switch marketing emails to campaign monitor

## [2.0.30] - 2021-09-13
### Added
- Unsubscribe from all list of campaign monitor

## [2.0.29] - 2021-09-03
### Changed
- Remake campaign monitor custom field quote_url

## [2.0.28] - 2021-08-31
### Fixed
- Disable resubscribe in campaign monitor header

## [2.0.27] - 2021-08-30
### Added
- Transfer requests statuses to campaign monitor in user custom field

## [2.0.26] - 2021-08-19
### Fixed
- Disable opt-in emails sending

## [2.0.25] - 2021-08-15
### Fixed
- Disable opt-in emails sending

## [2.0.24] - 2021-08-13
### Added
- Disable opt-in emails sending

## [2.0.23] - 2021-07-31
### Fixed
- Fix salesperson_email creation bug

## [2.0.22] - 2021-07-27
### Added
- Transfer sales person email to campaign manager in user custom field

## [2.0.21] - 2021-07-23
### Fixed
- Fix NameError in cm#update_subscriptions

## [2.0.20] - 2021-07-22
### Changed
- Split quote_url to 3 parts

## [2.0.19] - 2021-07-21
### Fixed
- Fixed MarketingEmail class validations

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
