import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/background.dart';
import 'package:rummy_tracker/game_flow/phase_two_tracking.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final (size, language) in [
    (const Size(320, 568), 'en'),
    (const Size(360, 800), 'bs'),
    (const Size(640, 360), 'en'),
  ]) {
    testWidgets('Empty scorecard fits $size in $language', (tester) async {
      SharedPreferences.setMockInitialValues({'app_language': language});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageService()),
            ChangeNotifierProvider(create: (_) => BackgroundService()),
          ],
          child: MaterialApp(
            home: PhaseTwoTrackingScreen(
              selectedPlayers: [
                Player(id: 'mia', name: 'Mia'),
                Player(id: 'leo', name: 'Leo'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final empty = find.byKey(const ValueKey('empty-rounds'));
      expect(empty, findsOneWidget);
      expect(
        find.text(language == 'bs' ? 'Spremni za bodove' : 'Ready to score'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);

      final addRound = find.widgetWithText(
        ElevatedButton,
        language == 'bs' ? 'DODAJ RUNDU' : 'ADD ROUND',
      );
      expect(
        tester.getRect(empty).bottom,
        lessThanOrEqualTo(tester.getRect(addRound).top),
      );
      // Exercise entry on the wide layout; compact cases check the empty state.
      if (size.width >= 400) {
        await tester.tap(addRound);
        await tester.pumpAndSettle();
        expect(empty, findsNothing);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  }
}
