# php-integrator/atom-linter-legacy-php56
## Legacy
This is a legacy version that requires PHP >= 5.6. Users that are on PHP 7.1 can and should use [the newer version](https://github.com/php-integrator/atom-base).

This package only exists to cater towards users that are not in any position to upgrade their host PHP version. As a result, any issues that appear in this package will not be fixed, no new features will be added and no enhancements will be done.

## About
This package provides linting for your PHP source code using [PHP Integrator](https://github.com/php-integrator/atom-base) as well as [linter](https://github.com/atom-community/linter).

**Note that the [php-integrator-base](https://github.com/php-integrator/atom-base) package is required and needs to be set up correctly for this package to function correctly.**

This package is not meant to be a replacement for existing PHP linters, but more as a complementary package that will indicate additional issues that the existing linters can't detect.

What is included?
  * Shows docblock issues.
  * Shows usage of unknown class members.
  * Shows usage of unknown global functions.
  * Shows usage of unknown global constants.
  * Shows warnings about unused use statements.
  * Shows erroneous class names that can't be resolved.
  * Shows errors returned by the base service's indexing process.

![GPLv3 Logo](http://gplv3.fsf.org/gplv3-127x51.png)
