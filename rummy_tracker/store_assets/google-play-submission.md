# Google Play submission — Rummy Tracker

Prepared 11 November 2026. Nothing has been uploaded or published.

## Release identity

- Developer brand: **Nightfall Studio**.
- Android package: `com.rummy.tracker`. Keep this for every future update.
- First upload: **3.1.2 (build 1)**, from `version: 3.1.2+1` in `pubspec.yaml`.
- Credits read the installed Android/iOS package metadata. Tap the Nightfall mark on the home screen to see it.
- Privacy URL: <https://rummy-tracker-web.vercel.app/privacy>. The home-screen shield opens this URL in the external browser. No game data is attached.
- Minimum Android API 24; target/compile API 36.

Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console. A named copy is kept in the repository's ignored `../output/play-release/` folder. APKs there are for local testing only.

## Listing copy

App name: **Rummy Tracker**

English short description:

> Keep score for Rummy games. Track rounds, resume games, and see wins offline.

English full description:

> Deal the cards. Rummy Tracker keeps the score.
>
> A companion for Rummy and Remi games played with physical cards. Add your players, record each round, and follow the totals without paper calculations.
>
> • Save players and select your group for each game.
> • Enter positive or negative scores, with quick presets for common penalties.
> • Follow round scores and running totals.
> • Resume an unfinished game after closing the app.
> • Finish a game and keep all-time win rankings.
> • Switch between English and Bosnian.
> • Choose from four table backgrounds.
>
> Play around the table, without accounts, ads, purchases, or an internet connection. Player names, scores, and preferences stay in app-private storage. Android system backups may apply according to your device settings.
>
> Rummy Tracker is a scorekeeper. Bring your own cards: the app does not deal cards, provide online opponents, accept wagers, or process payments.
>
> Made by Nightfall Studio.

Bosnian short description:

> Bilježite rezultate remija, nastavite partiju i pratite pobjede bez interneta.

Bosnian full description:

> Podijelite karte. Rummy Tracker vodi rezultate.
>
> Pratilac za remi koji igrate pravim kartama. Dodajte igrače, unesite bodove svake runde i pratite ukupne rezultate bez računanja na papiru.
>
> • Sačuvajte igrače i odaberite ekipu za partiju.
> • Unesite pozitivne ili negativne bodove uz brze prečice za česte kazne.
> • Pratite rezultate rundi i ukupan broj bodova.
> • Nastavite nedovršenu partiju nakon zatvaranja aplikacije.
> • Završite partiju i čuvajte rang-listu pobjeda.
> • Koristite aplikaciju na engleskom ili bosanskom jeziku.
> • Odaberite jednu od četiri pozadine.
>
> Igrajte za istim stolom, bez naloga, oglasa, kupovina i interneta. Imena igrača, bodovi i postavke čuvaju se u privatnoj pohrani aplikacije. Android može napraviti sistemsku sigurnosnu kopiju prema postavkama uređaja.
>
> Rummy Tracker bilježi rezultate. Ponesite svoje karte: aplikacija ne dijeli karte, nema mrežne protivnike, ne prima uloge i ne obrađuje plaćanja.
>
> Izradio Nightfall Studio.

Suggested first release notes:

> First Google Play release: offline Rummy scorekeeping, saved games, win rankings, English and Bosnian, and four table backgrounds.

## Store assets

- `google-play-icon.png`: 512 × 512 opaque RGBA PNG, under 1 MB.
- `google-play-feature-graphic.png`: 1024 × 500 RGB PNG. Generated with the built-in imagegen tool from the existing logo and website card-table reference, then downscaled/cropped to Play's dimensions. Prompt: `../../output/play-release/feature-graphic-prompt.md`.
- `screenshots/`: real captures of the bundle-derived release app on an Android 16 emulator, 1080 × 1920 RGB PNG. Example players and scores are fictional. Use the numbered English captures for the default listing.

Seven captures are ready: score table, score entry, player selection, home, players, winner, and win rankings. The emulator check also confirmed that four rounds survive a force-stop/relaunch, the lowest score wins, the winner receives one recorded win, credits show the bundle version, and the privacy button launches the external browser.

Prioritize the score table and score entry. Splash-only pictures do not explain the product. Revisit screenshots whenever visible functionality changes.

## Play Console checklist

1. Create **Rummy Tracker**, default language English, **free**. Recommended type **App**, category **Tools**, because this is a scorekeeping utility rather than a playable card game. Select accurate tags from the options Console actually offers.
2. Add the website, public support email, listing copy, icon, feature graphic, and screenshots. The existing website Contact link is a working email mechanism; the removed personal contact section does not need to return. Complete the account's required identity/device/contact verification using your real details.
3. Complete App content based on the shipped binary:
   - **Privacy policy:** the URL above, also accessible from the app.
   - **App access:** all functionality available without login or special instructions.
   - **Ads:** no.
   - **Data safety:** no developer collection or sharing of user data; no analytics, advertising SDKs, or advertising ID. Names and scores are processed locally. The OS backup caveat is disclosed in the policy. Do not claim that device backups are disabled.
   - **Account creation/deletion:** no accounts; account-deletion URL is not applicable. Local data can be removed through Android storage settings or uninstall, subject to OS backups.
   - **Content rating:** answer IARC's actual questions for an offline scorekeeper: no betting, simulated wagering, payments, user communication, or online multiplayer. IARC determines the rating; do not promise a particular rating in advance.
   - **Target audience:** choose the ages you actually intend to serve. Current policy says not directed to children under 13; keep the Console declaration and design consistent. Do not choose ages merely to avoid Families rules.
   - **Financial / health / news / government features:** none. This app does not take bets or provide gambling services. Complete any additional declarations shown on the dashboard accurately.
4. Enroll in **Play App Signing** and upload the signed AAB directly to **Closed testing**, as requested by the owner. Internal testing is optional and is being skipped. On the closed track, select the existing tester list already used by the other app in this developer account; do not change its members or the other app's testing configuration. Add a feedback contact, complete any required review, and record this app's opt-in link. Keep the existing upload keystore; back it and `android/key.properties` up securely outside Git.
5. Install from the Play opt-in link on your Samsung. Add players, enter positive/negative/preset scores, close and resume, finish a game, check win rankings, switch language/background, open the privacy link, and confirm credits show **3.1.2 · Build 1**. Review Play's pre-launch report, especially crashes and device compatibility.
6. If your personal developer account was created after **13 November 2023** and production access is locked: run a **Closed test with at least 12 testers continuously opted in for 14 days**, gather real usage/feedback, then apply for production access. Reusing a list does not opt people in to this app: testers must join through Rummy Tracker's own opt-in link. Testing time on another app does not transfer. Internal testing does not satisfy this gate. Access is reviewed, not automatic after the timer.
7. After access is granted and testing passes, choose distribution countries and submit production. Reuse/promote the same tested bundle when Console permits; a newly uploaded replacement needs a higher build number.

## Future builds

Edit only the version in `pubspec.yaml`, for example `3.1.3+2`, then run:

```powershell
flutter pub get
flutter test --timeout 30s
flutter build appbundle --release
```

Every new AAB upload needs a unique, increasing Android build number, including uploads to testing tracks. Credits automatically reflect the installed bundle, including explicit `--build-name` / `--build-number` overrides. Hot reload cannot change native version metadata; rebuild/reinstall to see a version change.

## Official references checked

- [Target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en): new submissions currently require API 36.
- [Privacy policy and user data](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en).
- [Data safety definitions and local processing](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).
- [Store graphic and screenshot specifications](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en).
- [Personal-account testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB).
- [Closed testing and reusable tester lists](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en).
- [16 KB support and validation](https://developer.android.com/guide/practices/page-sizes).

Windows cannot validate an iOS archive. The credits metadata implementation supports iOS, but an App Store release is a separate task.
