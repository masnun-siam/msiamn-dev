# Package Update Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update all 23 Flutter/Dart packages to their latest versions and fix all resulting breaking changes so the app compiles and builds cleanly.

**Architecture:** Same feature-first clean architecture. No structural changes — this is a dependency upgrade only. Breaking changes are isolated to provider signatures, notifier method patterns, and theme configuration.

**Tech Stack:** Flutter 3.38.9, Dart 3.10.8, Riverpod 3, Freezed 3, FlexColorScheme 8, google_fonts 8.

---

### Task 1: Update pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Replace the entire dependencies and dev_dependencies section**

Open `pubspec.yaml` and apply these changes:

```yaml
environment:
  sdk: '>=3.10.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flex_color_scheme: ^8.4.0
  google_fonts: ^8.0.2
  font_awesome_flutter: ^10.12.0
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2
  collection: ^1.19.1
  url_launcher: ^6.3.2
  url_strategy: ^0.3.0
  intl: ^0.20.2
  easy_localization: ^3.0.8
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0
  shared_preferences: ^2.5.4
  velocity_x: ^4.3.1
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  custom_lint: ^0.8.1
  riverpod_lint: ^3.1.3
  build_runner: ^2.12.2
  riverpod_generator: ^4.0.3
  freezed: ^3.2.5
  json_serializable: ^6.13.0
  flutter_native_splash: ^2.4.7
  flutter_launcher_icons: ^0.14.4
```

**Step 2: Run pub get**

```bash
flutter pub get
```

Expected: Resolves successfully. Localization hooks run automatically (generating `locale_keys.g.dart` and `locale_json.g.dart`). There will be analyzer errors — that's expected until subsequent tasks fix them.

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: update all packages to latest versions"
```

---

### Task 2: Fix Riverpod functional provider signatures

Riverpod 4 (riverpod_annotation 4.x) removed the generated per-provider `Ref` subtypes (e.g. `HomeSectionKeyRef`). Functional providers now use a unified `Ref` type from `riverpod_annotation`.

**Files:**
- Modify: `lib/src/features/main/provider/section_key_provider.dart`
- Modify: `lib/src/common/provider/shared_preferences_provider.dart`

**Step 1: Update section_key_provider.dart**

Replace the entire file content:

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'section_key_provider.g.dart';

@riverpod
GlobalKey homeSectionKey(Ref ref) {
  return GlobalKey();
}

@riverpod
GlobalKey aboutSectionKey(Ref ref) {
  return GlobalKey();
}

@riverpod
GlobalKey experienceSectionKey(Ref ref) {
  return GlobalKey();
}

@riverpod
GlobalKey projectSectionKey(Ref ref) {
  return GlobalKey();
}
```

**Step 2: Update shared_preferences_provider.dart**

Replace the entire file content:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@riverpod
FutureOr<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}
```

**Step 3: Commit**

```bash
git add lib/src/features/main/provider/section_key_provider.dart \
        lib/src/common/provider/shared_preferences_provider.dart
git commit -m "fix: update functional provider signatures for Riverpod 4"
```

---

### Task 3: Fix ref.watch → ref.read in notifier methods

In Riverpod 3+, calling `ref.watch` inside notifier methods (outside of `build()`) is a lint error. These must use `ref.read`.

**Files:**
- Modify: `lib/src/features/main/provider/dark_mode_controller.dart` (line 17)
- Modify: `lib/src/features/main/provider/brightness_controller.dart` (line 46)

**Step 1: Fix dark_mode_controller.dart**

Change line 17 from:
```dart
await ref.watch(brightnessControllerProvider.notifier).updateBrightness();
```
To:
```dart
await ref.read(brightnessControllerProvider.notifier).updateBrightness();
```

**Step 2: Fix brightness_controller.dart**

Change line 46 from:
```dart
ref.watch(sharedPreferencesProvider).whenData((sharedPreferences) async {
```
To:
```dart
ref.read(sharedPreferencesProvider).whenData((sharedPreferences) async {
```

**Step 3: Commit**

```bash
git add lib/src/features/main/provider/dark_mode_controller.dart \
        lib/src/features/main/provider/brightness_controller.dart
git commit -m "fix: replace ref.watch with ref.read in notifier methods (Riverpod 3)"
```

---

### Task 4: Fix FlexColorScheme 8 breaking changes

`swapLegacyOnMaterial3` was removed in FlexColorScheme v8 (it was deprecated in v7). Remove it from both themes.

**Files:**
- Modify: `lib/src/constants/themes.dart`

**Step 1: Remove swapLegacyOnMaterial3 from darkTheme (line 70)**

Remove this line from the `FlexThemeData.dark(...)` call:
```dart
  swapLegacyOnMaterial3: true,
```

**Step 2: Remove swapLegacyOnMaterial3 from lightTheme (line 146)**

Remove this line from the `FlexThemeData.light(...)` call:
```dart
  swapLegacyOnMaterial3: true,
```

**Step 3: Also update the comment on line 76-79** to remove the outdated version note (it says "Made for FlexColorScheme version 7.0.0"). Replace with:
```dart
// Theme configured for FlexColorScheme version 8.x.
```

**Step 4: Commit**

```bash
git add lib/src/constants/themes.dart
git commit -m "fix: remove swapLegacyOnMaterial3 removed in FlexColorScheme 8"
```

---

### Task 5: Regenerate all code

Now that provider signatures are corrected, regenerate all `.g.dart` and `.freezed.dart` files.

**Step 1: Delete stale generated files if any exist**

```bash
find lib -name "*.g.dart" -o -name "*.freezed.dart" | xargs rm -f 2>/dev/null; echo "done"
```

**Step 2: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected output: Build succeeded. Generated files:
- `lib/src/features/main/provider/dark_mode_controller.g.dart`
- `lib/src/features/main/provider/brightness_controller.g.dart`
- `lib/src/features/main/provider/section_key_provider.g.dart`
- `lib/src/common/provider/shared_preferences_provider.g.dart`
- `lib/src/features/project/domain/project.freezed.dart`
- `lib/src/features/project/domain/project.g.dart`
- `lib/src/features/experience/domain/experience.freezed.dart`
- `lib/src/features/experience/domain/experience.g.dart`
- `lib/src/features/introduction/domain/contact.freezed.dart`
- `lib/src/features/introduction/domain/contact.g.dart`
- `lib/src/features/introduction/domain/resume.freezed.dart`
- `lib/src/features/introduction/domain/resume.g.dart`
- `lib/src/common/domain/link.freezed.dart`
- `lib/src/common/domain/link.g.dart`
- `lib/src/common/domain/language.freezed.dart`
- `lib/src/common/domain/language.g.dart`

If build fails with errors, read them carefully — each error will point to the specific file and line. Fix errors before moving on.

**Step 3: Commit generated files**

```bash
git add lib/
git commit -m "chore: regenerate all code for Riverpod 4 and Freezed 3"
```

---

### Task 6: Run analyzer and fix lint issues

`flutter_lints` v3→v6 added new rules that may flag existing code.

**Step 1: Run the analyzer**

```bash
flutter analyze
```

**Step 2: Fix any reported issues**

Common issues from flutter_lints 4-6 include:
- `use_super_parameters` — replace `Key? key` constructor args with `super.key`
- `unnecessary_constructor_name` — `.new` cleanup
- `deprecated_member_use` — any Flutter SDK deprecations

Fix each reported file. The analyzer output shows `file.dart:line:col: message` — go to each location and apply the suggested fix.

**Step 3: Re-run to confirm zero issues**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/
git commit -m "fix: resolve flutter_lints v6 analyzer warnings"
```

---

### Task 7: Verify web build

**Step 1: Run the release web build**

```bash
flutter build web --web-renderer canvaskit --release --no-tree-shake-icons
```

Expected: `✓ Built build/web` with no errors.

If there are runtime/build errors, read the full error output. Common issues:
- Missing imports after Riverpod 4 codegen — add `import 'package:flutter_riverpod/flutter_riverpod.dart';` where needed
- google_fonts 8 may require `GoogleFonts.config.allowRuntimeFetching = false` for offline builds — add to `main()` if build warns about it

**Step 2: Commit if any fixes were needed**

```bash
git add lib/
git commit -m "fix: resolve web build issues after package update"
```

---

### Task 8: Final commit summary

**Step 1: Verify clean state**

```bash
git status
flutter analyze
```

Both should be clean.

**Step 2: Tag the update (optional)**

```bash
git log --oneline -8
```

Review all commits from this update session to confirm the upgrade is complete and coherent.
