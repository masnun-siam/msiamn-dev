#!/bin/bash
/Users/siam/development/flutter/bin/cache/dart-sdk/bin/dart run easy_localization:generate -S assets/translations -f keys -O lib/src/localization/generated -o locale_keys.g.dart
/Users/siam/development/flutter/bin/cache/dart-sdk/bin/dart run easy_localization:generate -S assets/translations -f json -O lib/src/localization/generated -o locale_json.g.dart
