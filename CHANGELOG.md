## 1.0.0 (base 1.0.0)
* Don't show unused use statements when there are syntax errors.
  * Sometimes a syntax error results in a statement being ignored, in turn causing the linter to mark a use statement incorrectly as unused. This mitigates that behavior.

## 0.3.0 (base 0.9.0)
* There is now a settings screen to disable certain aspects of the linting process.
* The linter can now utilize the new functionality of the base service to lint docblock correctness (enabled by default).
* Due to changes in the base service, multiple syntax errors can now be shown at the same time in some cases (instead of the next popping up after correcting the first).

## 0.2.2 (base 0.8.0)
* Update to use the most recent version of the base service.

## 0.2.1
* Catch errors when no linter is set.

## 0.2.0 (base 0.7.0)
* Show warnings about unused use statements.
* Show erroneous class names that can't be resolved.

## 0.1.0
* Initial release.
