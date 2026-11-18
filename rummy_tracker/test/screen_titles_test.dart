import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/background.dart';
import 'package:rummy_tracker/game_flow/phase_one_selection.dart';
import 'package:rummy_tracker/game_flow/phase_two_tracking.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:rummy_tracker/players_section/players_screen.dart';
import 'package:rummy_tracker/ranking_section/ranking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('All four titles stay centered on one line and fit the header', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final language in ['en', 'bs']) {
      for (final (width, textScale) in [
        (320.0, 1.0),
        (360.0, 1.0),
        (430.0, 1.25),
        (768.0, 1.0),
      ]) {
        tester.view.physicalSize = Size(width, 800);
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        for (final (screen, titleKey) in <(Widget, String)>[
          (const PlayersScreen(), 'players'),
          (const RankingScreen(), 'ranking'),
          (const PhaseOneScreen(), 'select_players'),
          (
            PhaseTwoTrackingScreen(
              selectedPlayers: [
                Player(id: 'mia', name: 'Mia'),
                Player(id: 'leo', name: 'Leo'),
              ],
            ),
            'points_tracker',
          ),
        ]) {
          SharedPreferences.setMockInitialValues({'app_language': language});
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => LanguageService()),
                ChangeNotifierProvider(create: (_) => BackgroundService()),
              ],
              child: MaterialApp(
                theme: ThemeData(
                  brightness: Brightness.dark,
                  useMaterial3: true,
                ),
                home: screen,
              ),
            ),
          );
          await tester.pumpAndSettle();

          final context = tester.element(find.byType(screen.runtimeType));
          final title = context.read<LanguageService>().translate(titleKey);
          final titleFinder = find.text(title);
          final paragraph = tester.renderObject<RenderParagraph>(titleFinder);
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: title.length),
          );
          final reason = '$title at $width, text scale $textScale';
          expect(boxes, hasLength(1), reason: reason);
          final bounds = MatrixUtils.transformRect(
            paragraph.getTransformTo(null),
            Offset.zero & paragraph.size,
          );
          expect(bounds.center.dx, closeTo(width / 2, 0.5), reason: reason);
          final header = find
              .ancestor(of: titleFinder, matching: find.byType(Row))
              .first;
          final control = tester.getRect(
            find
                .descendant(of: header, matching: find.byType(IconButton))
                .first,
          );
          expect(
            bounds.left,
            greaterThanOrEqualTo(control.right),
            reason: reason,
          );
          expect(
            bounds.right,
            lessThanOrEqualTo(width - control.right),
            reason: reason,
          );
          expect(
            paragraph.getTransformTo(null).getMaxScaleOnAxis(),
            lessThanOrEqualTo(1.001),
            reason: reason,
          );
          expect(tester.takeException(), isNull, reason: reason);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    }
  });
}
