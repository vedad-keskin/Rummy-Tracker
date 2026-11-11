# Store assets

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

Google Play also has `google-play-feature-graphic.png` (1024 × 500 RGB) and numbered, real app captures in `screenshots/` (1080 × 1920 RGB). Listing copy, release identity, validation notes, and the remaining Console steps are in [google-play-submission.md](google-play-submission.md).

The feature graphic was made with the built-in imagegen tool from the selected logo and the website's card-table reference. The final prompt is saved at `../../output/play-release/feature-graphic-prompt.md`; raw generations and release binaries stay outside Git in the ignored `output/` folder.

The signed upload bundle is `../../output/play-release/rummy-tracker-3.1.2-1.aab`. Credits read **3.1.2 · Build 1** from the installed bundle. This is the first upload; newly uploaded replacements must increment the build number.

Play Console upload and iOS archive validation have not been performed.
