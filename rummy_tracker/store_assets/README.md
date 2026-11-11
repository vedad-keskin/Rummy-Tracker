# Store icons

The selected Vibrant Remix logo is the master at `assets/images/logo_transparent.png`.

- `google-play-icon.png`: 512 × 512, 32-bit PNG with an opaque navy background, square corners, under 1 MB.
- `app-store-icon.png`: 1024 × 1024 RGB PNG, opaque navy background, square corners.

Google Play and Apple apply their own icon masks. Keep these files square.

From `rummy_tracker`, regenerate all launcher, native splash, website and store assets with:

```sh
dart run tool/generate_branding.dart
```

Verify the generated sizes, opacity and Android/web mask safe zones without changing files:

```sh
dart run tool/generate_branding.dart --check
```

References: [Google Play icon specification](https://developer.android.com/distribute/google-play/resources/icon-design-specifications), [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive), [Apple asset catalog icons](https://developer.apple.com/documentation/xcode/configuring-your-app-icon).

These are icon assets only; store submission and iOS build validation are separate steps.
