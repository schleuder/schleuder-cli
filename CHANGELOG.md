Change Log
==========

This project adheres to [Semantic Versioning](http://semver.org/).

The format of this file is based on [Keep a Changelog](http://keepachangelog.com/).

## Unreleased


## [0.2.0] / 2024-03-08

### Changed

* Make the error message if a resource could not be found a little friendlier.
* If a key file given to `lists new` does not exist, don't create the list in the first place.
* For each imported key show a key summary, not just the fingerprint (if provided by the API daemon, which it will do/does from version 5.0.0 on).
* Update the gem "thor" to version 1.0.
* Use "base64" as gem if Ruby is v3.3 (or later), because in v3.4 it's being removed from the standard library.

### Fixed

* Fix compatibility with ruby 3.0 by changing how values are escaped.


## [0.1.0] / 2017-07-21

### Added

* New sub-command for lists: send-list-key-to-subscriptions. It instructs Schleuder to send the public key of the list to all of its subscriptions. Very useful after the setup of a new list.

### Changed

* When subscribing an address, fingerprint and key-file are mutually exclusive now. With a key-file we now use the fingerprint of the imported key (if it was exactly one — otherwise you'll see an error-message). Previously you'd have to provide fingerprint *and* key-file to have the key imported and assigned.


## [0.0.4] / 2017-04-15

### Fixed

* `keys check` now uses the correct backend-URL.


## [0.0.3] / 2017-01-26

### Changed

* Always use TLS.
* Required version of schleuder: 3.0.0.


## [0.0.2] / 2017-01-25

### Changed

* Always send API-key.
* Required version of schleuder: 3.0.0rc1.

### Fixed

 * Use section 8 instead of 1 for manpage.
 * Use correct link to schleuder in README.


## [0.0.1] / 2017-01-25

### Changed

 * Use section 1 instead of 8 for manpage.
 * Providing a key for the admin is now optional when creating new lists.

### Fixed

 * Fixed importing binary OpenPGP-keys.

### Added

 * Show a hint if delivery is disabled for a subscription when listing them.


## 0.0.1.beta13

### Changed

 * Flat config file, no nested keys anymore.
 * Fix tarball to contain correct data.
 * Create basedir of config if necessary.

## 0.0.1.beta12

### Changed

 * Write default config if none exists yet, let only user+group access it.


## [before]

### Added

 * Everything.

