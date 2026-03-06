## 1.0.0

First stable release with new public models, enums, and `Duration`-based timings.

* **New Features**
  * Added public models for cache entries, page timings, params, DevTools initiator/stack/frames, and WebSocket messages; added DevTools enums and parsing/duration helpers.

* **Breaking Changes**
  * All timing fields and total times now use Duration objects.
  * DevTools priority/resourceType are enums.
  * WebSocket messages are typed objects instead of raw maps.

* **Documentation**
  * Examples updated to show Duration-based timings and new DevTools types.

* **Tests**
  * Expanded tests covering new models, parsing, and Duration behavior.

## 0.1.1

* Initial version.
