## 1.3.1
* Rename package to demarcate legacy status.

## 1.3.0 (base 2.0.0)
* Mark `show unknown members` as experimental.

## 1.2.1
* Rename the package and repository.

## 1.2.0
* It is now possible to disable warnings about missing documentation (thanks to [@hultberg](https://github.com/hultberg)).

## 1.1.0 (base 1.1.0)
* Unknown global functions are now displayed.
* Unknown global constants are now displayed.
* Unknown class members are now displayed (disabled by default).
* Linting will now less aggressively respond to every index. This prevents a flood of linting processes being spawned if the file being linted is long and many edits are being made (subsequently causing quick successive reindexes).

## 1.0.1
* Fixed warning and error offsets when using Unicode characters.

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
