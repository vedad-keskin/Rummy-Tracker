# Rummy Tracker

A Flutter mobile app for tracking scores and all-time win rankings across Rummy (Remi) card game sessions. Fully offline, with support for English and Bosnian.

---

## Features

- **Live score tracking** — Add rounds one player at a time with preset score buttons (`-40`, `-140`, `-500`) or free-entry input
- **Auto-sort leaderboard** — Players are re-ranked by total score after every round (lowest score wins)
- **Session resume** — In-progress games are auto-saved and can be resumed after closing the app
- **Player management** — Add, rename, and delete players from a persistent roster
- **All-time rankings** — Leaderboard tracking career wins across all sessions
- **Dynamic game editing** — Edit past round scores, remove players mid-game, or add new players to an ongoing session
- **Bilingual UI** — Full English and Bosnian language support, switchable at any time
- **Animated UI** — Splash screen, card suit animations, score transitions, and screen change effects throughout

---

## Scoring System

Rummy uses a **lowest-score-wins** model. Points are negative:

| Event | Points |
|---|---|
| Regular Win | −40 |
| Going Out (Hand) | −140 |
| Rummy Win | −500 |
| Custom | any integer |

---

## Screens

| Screen | Description |
|---|---|
| Splash | Animated launch screen with orbiting card suit symbols |
| Main Menu | Entry point with Play, Players, and Rankings navigation |
| Player Selection | Choose 2+ players from the roster to start a game |
| Score Tracking | Core game screen — round entry, live table, and game controls |
| Winner Screen | Celebration screen showing the winner and final session standings |
| Players | Add, edit, and delete the player roster |
| Rankings | All-time win leaderboard with gold/silver/bronze styling |

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart SDK `^3.9.2`) |
| State management | `provider ^6.1.2` |
| Local storage | `shared_preferences ^2.3.3` |
| Localization | Custom lightweight i18n (flat string maps, no `flutter_localizations`) |
| Theme | Material 3, dark mode only, seeded from `Colors.deepPurple` |
| Networking | None — fully offline |

---

## Project Structure

```
lib/
├── main.dart                          # App entry, Provider setup
├── layouts/
│   ├── splash_screen.dart             # Animated launch screen
│   └── main_layout.dart               # Main menu
├── game_flow/
│   ├── phase_one_selection.dart       # Player selection
│   ├── phase_two_tracking.dart        # Live score tracking
│   └── phase_three_win.dart           # Winner celebration
├── players_section/
│   └── players_screen.dart            # Player CRUD
├── ranking_section/
│   └── ranking_screen.dart            # All-time leaderboard
├── components/
│   ├── how_to_play_button.dart
│   ├── rules_dialog.dart              # Paginated rules dialog
│   ├── language_switch.dart           # EN / BS toggle
│   └── team_credits_dialog.dart       # Easter egg credits
└── offline_db/
    ├── player_service.dart            # Player model + persistence
    ├── game_state_service.dart        # Game state save/restore
    ├── language_service.dart          # Language ChangeNotifier
    ├── translations_en.dart
    └── translations_bs.dart
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- An Android or iOS device/emulator

### Run

```bash
flutter pub get
flutter run
```

### Build (Android)

```bash
flutter build apk --release
```

---

## Version

**v3.1.2**
