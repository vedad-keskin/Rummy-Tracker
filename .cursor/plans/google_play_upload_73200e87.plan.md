---
name: Google Play upload
overview: Prepare Rummy Tracker as a free offline scorekeeper. Signing and package identity are configured; the signed first bundle and store materials are prepared locally. Play Console upload and testing remain manual.
todos:
  - id: package-id
    content: Use the permanent Android package com.rummy.tracker
    status: completed
  - id: signing
    content: Sign release builds with the existing external upload keystore
    status: completed
  - id: policy-listing
    content: Verify the live Nightfall Studio privacy policy and prepare listing copy
    status: completed
  - id: in-app-policy
    content: Before Play submission, choose an in-app privacy text or link location without adding a privacy button
    status: pending
  - id: version-credits
    content: Show only the installed version under Close in hold-to-open credits
    status: completed
  - id: aab
    content: Build and validate the signed 3.1.2 build 1 release bundle
    status: completed
  - id: store-assets
    content: Prepare the icon, feature graphic, listing copy, and real phone-format screenshots
    status: completed
  - id: console-testing
    content: Complete Play Console declarations, upload directly to closed testing, reuse the existing tester list, and perform the Samsung acceptance check
    status: pending
  - id: production-access
    content: Complete required closed testing and apply for production access if this personal account is gated
    status: pending
isProject: false
---

# Google Play upload — audited 11 November 2026

The original package/signing/AAB approach was sound. This plan now reflects the deployed policy, current app, and current official Play requirements. Nothing has been uploaded or published. The owner confirmed this is a personal account and no previous bundle has been uploaded.

## Prepared release

- App: **Rummy Tracker**, developer brand **Nightfall Studio**.
- Android package: `com.rummy.tracker`; keep it unchanged after first upload.
- `pubspec.yaml`: **3.1.2+1**, giving Android version name **3.1.2** and build/version code **1**.
- Hold the home-screen Nightfall mark to open credits; tapping does not reveal them. Only `v 3.1.2` appears below Close, read from installed Android/iOS package metadata. The build number is kept in the package metadata and is not displayed.
- Signing remains configured through ignored `android/key.properties` and the existing upload keystore outside the repository. No signing material is embedded in the app or store materials.
- Release AAB: `rummy_tracker/build/app/outputs/bundle/release/app-release.aab`.
- Named upload copy: `output/play-release/rummy-tracker-3.1.2-1.aab` (ignored by Git).
- AAB SHA-256: `082735EED85388410E6E26182D2AC988DE49DE3A5466581172F7806DA89493C5`.

## Corrections to the original plan

1. **Policy is already deployed:** <https://rummy-tracker-web.vercel.app/privacy> returned HTTP 200. It identifies the app and Nightfall Studio, covers local storage, OS backups, deletion, website hosting, and has a working Contact email mechanism in the site navigation/footer. No personal contact section needs to return.
2. **In-app privacy remains a submission item:** the owner requested removal of the mobile privacy button. It and its browser-launch dependency have been removed. The web policy remains live; before Play submission, an in-app policy text or link location still needs to be chosen without adding a privacy button.
3. **Listing copy is local:** the obsolete `/listing` page was deliberately removed. Use `rummy_tracker/store_assets/google-play-submission.md` for English/Bosnian descriptions, release notes, exact asset paths, and Console instructions.
4. **Choose an accurate app type:** recommended **App / Tools** for this physical-card scorekeeping utility. The old plan mixed App and Game/Cards. Describe scorekeeping clearly; do not imply playable cards, online multiplayer, or wagering.
5. **Do not preselect an IARC result:** answer the questionnaire honestly and let IARC calculate the rating. Choose the actual intended audience; do not select ages only to avoid Families rules. The current policy says the app is not directed to under-13s.
6. **Verify the finished bundle:** NDK version alone does not prove 16 KB support. Validation checked bundle configuration, packaged 64-bit ELF LOAD/RELRO alignment, and APK zip alignment.
7. **Personal-account gate is conditional:** if the account was created after 13 November 2023 and production is locked, at least 12 testers must stay opted in to a closed test for 14 consecutive days, followed by a production-access application. Internal testing does not count toward that gate.

## Validation completed

- Signed release AAB built successfully with Flutter 3.44.2.
- Google bundletool validation passed; JAR signature verified.
- Manifest: package `com.rummy.tracker`, version **3.1.2 (1)**, min SDK **24**, target/compile SDK **36**, not debuggable, no Internet or advertising-ID permission.
- Bundle native-library packing: `PAGE_ALIGNMENT_16K`.
- All six arm64-v8a/x86_64 native libraries passed 16 KB ELF LOAD and RELRO checks.
- A universal APK generated from the AAB passed `zipalign -c -P 16 4`. This derivative is locally debug-signed for testing; upload the original release-signed AAB to Play.
- Branding dimensions, opacity, and mask safe zones passed the existing branding checker.
- Android 16 emulator game smoke test passed: edit/add four players, select a game, enter four rounds with positive/negative presets, force-stop and resume all rounds, finish with the correct lowest-score winner, and verify the winner receives one all-time win. Seven real 1080 x 1920 screenshots were captured.
- Nine widget tests passed, including hold-only credits, metadata-driven `v 3.1.2` below Close, no home privacy button, English/Bosnian localization, intro, backgrounds, and compact screens.
- The rebuilt bundle was checked on the Android 16 emulator: tapping Nightfall leaves credits hidden, holding reveals `v 3.1.2` below Close, and the home privacy button is absent. The home store screenshot was refreshed from that build.
- Focused analysis has no errors/warnings; the existing `withOpacity` / asynchronous BuildContext infos remain. Gradle/AGP/Kotlin future-support notices do not block this successful release build; no toolchain migration is needed for this submission.
- Runtime testing on a real 16 KB device/emulator is still recommended; static alignment checks are not a substitute for that test. Play's device/pre-launch reports remain part of release review.

## Next: Play Console — closed testing directly

The owner requested skipping internal testing and reusing the tester list already used by another app in this developer account. Internal testing is optional. Complete app setup, then start the closed test directly. Reusing a list grants eligibility; testers still need to opt in to Rummy Tracker specifically. Testing time from another app does not transfer.

Console URL: <https://play.google.com/console/u/0/developers/7479752174002745096/home>.

Automation access check: the Browser tool returned `No browser is available`; the Computer Use tool could not connect to its native desktop pipe. No Console changes, uploads, or submissions have been made. Resume Console work once the logged-in browser is exposed to this chat.

Follow `rummy_tracker/store_assets/google-play-submission.md`:

1. Back up the upload keystore and its credentials securely outside Git. Complete the developer account's identity, contact, and device verification if prompted.
2. Create the free app, complete its listing and App content declarations, provide the live privacy URL, and enroll in Play App Signing.
3. Upload the AAB directly to Closed testing, select the existing tester list used by the other app without modifying that list, and make the closed release available after any required review. Record the new Rummy Tracker opt-in link for the owner to share. Install through that link on the Samsung.
4. Run the full acceptance checklist and review Play's pre-launch results.
5. Complete the closed-test/production-access gate if Console requires it, then submit production only after testing passes.

Every newly uploaded AAB needs an increasing version code. To change the version later, edit `pubspec.yaml` and rebuild/reinstall; hot reload cannot update native metadata.

## Official sources

- [Target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en): API 36 required for new submissions since 31 August 2026; the current target is sufficient.
- [User Data / privacy policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en).
- [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).
- [Store assets](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en).
- [Testing for personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB).
- [16 KB page sizes](https://developer.android.com/guide/practices/page-sizes).

No website redeployment is needed for these app changes. An iOS archive / App Store submission remains outside this Android preparation task.
