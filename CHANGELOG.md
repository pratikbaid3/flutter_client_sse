## [2.1.0] - Migrated to null safety.

* Closes the `StreamController` before closing the http client.
## [0.0.2] - Migrated to null safety.

* The package is now null safe
* Unused imports have been removed

## [0.0.3] - Added example for consuming a event.

* Added a example dart file for consuming the event
* Refactored the code to remove redundancy

## [0.0.4] - Refactored example

## [0.0.5] - Improved the stability

* Fixed issue causing large responses to be split
* Improved the way UTF8 Encoder was used

## [0.0.6] - Fixed Stackoverflow exception

* Fixed issue causing stackoverflow while loading large chunk data stream

## [0.1.0] - Improved documentation

* Added In-line documentation

## [1.0.0] - Custom header and error handling

* Added ability to send custom headers
* Added error handling

## [2.0.0-beta.1] - Ability to choose between GET and POST request and send a body with the request[BREAKING CHANGE]

* The request type can now be manually set
* Ability to pass the request body with the request
* Safe close of the sink added as well which was causing some minor crashes

## [2.0.0] - Ability to choose between GET and POST request and send a body with the request[BREAKING CHANGE] and some additional code refactoring and bug fixes 

* The request type can now be manually set
* Ability to pass the request body with the request
* Safe close of the sink added as well which was causing some minor crashes
* Stability changes in the model to handle null safety