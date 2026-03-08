# Package Update Design

**Date:** 2026-03-08
**Scope:** Full update of all Flutter/Dart packages to latest versions, including major version migrations.

## Context

Packages were last updated in March 2024 (~2 years). `flutter pub get` currently fails due to an `intl` version conflict. Flutter 3.38.9 / Dart 3.10.8 is installed locally.

## Package Versions

| Package | Current | Latest | Type |
|---|---|---|---|
| flutter_riverpod | ^2.3.6 | 3.2.1 | MAJOR |
| riverpod_annotation | ^2.1.1 | 4.0.2 | MAJOR |
| riverpod_generator | ^2.2.3 | 4.0.3 | MAJOR |
| riverpod_lint | ^2.3.9 | 3.1.3 | MAJOR |
| freezed | ^2.4.1 | 3.2.5 | MAJOR |
| freezed_annotation | ^2.4.1 | 3.1.0 | MAJOR |
| flex_color_scheme | ^7.1.2 | 8.4.0 | MAJOR |
| google_fonts | ^6.2.1 | 8.0.2 | MAJOR |
| flutter_lints | ^3.0.1 | 6.0.0 | MAJOR |
| intl | ^0.18.0 | 0.20.2 | conflict fix |
| collection | ^1.17.1 | 1.19.1 | minor |
| url_launcher | ^6.1.11 | 6.3.2 | minor |
| url_strategy | ^0.2.0 | 0.3.0 | minor |
| easy_localization | ^3.0.2 | 3.0.8 | minor |
| json_annotation | ^4.8.1 | 4.11.0 | minor |
| shared_preferences | ^2.2.0 | 2.5.4 | minor |
| velocity_x | ^4.1.2 | 4.3.1 | minor |
| cached_network_image | ^3.3.1 | 3.4.1 | minor |
| custom_lint | ^0.6.2 | 0.8.1 | minor |
| build_runner | ^2.4.8 | 2.12.2 | minor |
| json_serializable | ^6.7.1 | 6.13.0 | minor |
| flutter_native_splash | ^2.3.1 | 2.4.7 | minor |
| flutter_launcher_icons | ^0.13.1 | 0.14.4 | minor |

## Codebase Inventory

- **Riverpod providers:** 5 files with `@riverpod`, 1 with `NotifierProvider`, ~10 consuming widgets
- **Freezed models:** 6 domain models (project, experience, contact, resume, link, language)
- **FlexColorScheme:** 1 file (`lib/src/constants/themes.dart`) with extensive API usage
- **google_fonts:** 1 file (`lib/src/constants/themes.dart`) using `GoogleFonts.nunito().fontFamily`
- **url_strategy:** `setPathUrlStrategy()` in `lib/main.dart`
- **Generated files:** 14 expected (4 Riverpod, 6 Freezed, 4 JSON, 2 localization)

## Phases

### Phase 1 — pubspec.yaml update
Update all packages to latest versions. Update SDK constraint to `>=3.10.0 <4.0.0`.

### Phase 2 — Regenerate code
Run `dart run build_runner build --delete-conflicting-outputs`. Localization files are auto-generated via pubspec hooks on `pub get`.

### Phase 3 — Fix Riverpod 2→3 breaking changes
Riverpod 3 changes codegen output. Review the 4 annotated provider files and ~10 consumers for any ref/watch API changes.

### Phase 4 — Fix Freezed 2→3 breaking changes
Freezed 3 changed nullable `copyWith` semantics. Review the 6 domain models post-regeneration.

### Phase 5 — Fix FlexColorScheme 7→8
`swapLegacyOnMaterial3` removed in v8, some `FlexSubThemesData` fields renamed. One file: `lib/src/constants/themes.dart`.

### Phase 6 — Fix google_fonts 6→8
`GoogleFonts.nunito().fontFamily` pattern expected to still work. Verify no changes needed.

### Phase 7 — Analyze + build
Run `flutter analyze` to catch lint issues from flutter_lints v3→v6, then `flutter build web --web-renderer canvaskit --release --no-tree-shake-icons` for final verification.
