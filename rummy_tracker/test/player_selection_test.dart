import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/background.dart';
import 'package:rummy_tracker/components/card_artwork.dart';
import 'package:rummy_tracker/game_flow/phase_one_selection.dart';
import 'package:rummy_tracker/game_flow/phase_two_tracking.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder card(String id) => find.byKey(ValueKey('selection-card-$id'));

Finder cardFade(String id) =>
    find.ancestor(of: card(id), matching: find.byType(FadeTransition)).first;

Future<void> openSelection(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => BackgroundService()),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        home: const PhaseOneScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'rummy_players': jsonEncode([
        {'id': 'mia', 'name': 'Mia', 'wins': 3},
        {'id': 'leo', 'name': 'Leo', 'wins': 1},
        {'id': 'long', 'name': 'Alexandria Montgomery', 'wins': 12},
        for (var i = 4; i <= 10; i++)
          {'id': '$i', 'name': 'Player $i', 'wins': 0},
      ]),
      'rummy_selected_ids': ['mia', 'leo'],
    });
  });

  testWidgets('Cards fade, keep their identity, and preserve selection rules', (
    tester,
  ) async {
    await openSelection(tester);
    final paint = tester.widget<CustomPaint>(card('mia'));
    final suit = (paint.painter! as AcePainter).suit;
    final rotation = tester
        .widget<Transform>(
          find
              .ancestor(of: card('mia'), matching: find.byType(Transform))
              .first,
        )
        .transform
        .storage
        .toList();
    expect(tester.widget<FadeTransition>(cardFade('mia')).opacity.value, 1);
    expect(tester.widget<FadeTransition>(cardFade('long')).opacity.value, 0);

    await tester.tap(find.text('Mia'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester.widget<FadeTransition>(cardFade('mia')).opacity.value,
      allOf(greaterThan(0), lessThan(1)),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(cardFade('mia')).opacity.value, 0);
    expect(
      (await SharedPreferences.getInstance()).getStringList(
        'rummy_selected_ids',
      ),
      ['leo'],
    );
    await tester.tap(find.text('START GAME'));
    await tester.pumpAndSettle();
    expect(find.byType(PhaseTwoTrackingScreen), findsNothing);

    // Tapping the card's area inside the row still selects the player.
    await tester.tapAt(tester.getCenter(card('mia')));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(cardFade('mia')).opacity.value, 1);
    expect(
      (tester.widget<CustomPaint>(card('mia')).painter! as AcePainter).suit,
      suit,
    );
    expect(
      tester
          .widget<Transform>(
            find
                .ancestor(of: card('mia'), matching: find.byType(Transform))
                .first,
          )
          .transform
          .storage,
      orderedEquals(rotation),
    );
    expect(
      (await SharedPreferences.getInstance()).getStringList(
        'rummy_selected_ids',
      ),
      unorderedEquals(['mia', 'leo']),
    );
    await tester.tap(find.text('START GAME'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PhaseTwoTrackingScreen>(find.byType(PhaseTwoTrackingScreen))
          .selectedPlayers
          .map((player) => player.id),
      ['mia', 'leo'],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Cards fit compact, landscape and large text with reduced motion',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      for (final (size, textScale, language) in [
        (const Size(320, 568), 1.0, 'en'),
        (const Size(640, 360), 1.0, 'bs'),
        (const Size(360, 800), 2.0, 'bs'),
      ]) {
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        await (await SharedPreferences.getInstance()).setString(
          'app_language',
          language,
        );
        await openSelection(tester);
        final box = tester.renderObject<RenderBox>(card('mia'));
        final bounds = MatrixUtils.transformRect(
          box.getTransformTo(null),
          Offset.zero & box.size,
        );
        final row = tester.getRect(
          find.ancestor(of: card('mia'), matching: find.byType(Stack)).first,
        );
        expect(bounds.left, greaterThanOrEqualTo(row.left));
        expect(bounds.right, lessThanOrEqualTo(row.right));
        expect(
          bounds.top,
          greaterThan(tester.getRect(find.byType(ListView)).top),
        );
        expect(bounds.bottom, lessThan(row.top + 35));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Mia'));
        await tester.pump();
        expect(tester.widget<FadeTransition>(cardFade('mia')).opacity.value, 0);
        await tester.tap(find.text('Mia'));
        await tester.pump();
        expect(tester.widget<FadeTransition>(cardFade('mia')).opacity.value, 1);

        await tester.scrollUntilVisible(
          find.text('Alexandria Montgomery'),
          100,
        );
        await tester.pumpAndSettle();
        final longCard = tester.renderObject<RenderBox>(card('long'));
        expect(
          MatrixUtils.transformRect(
            longCard.getTransformTo(null),
            Offset.zero & longCard.size,
          ).overlaps(tester.getRect(find.text('Alexandria Montgomery'))),
          isFalse,
        );

        await tester.scrollUntilVisible(find.text('Player 10'), 150);
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(find.text('Player 10')),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Player 10').hitTestable(),
          findsOneWidget,
          reason:
              '$size, text $textScale: '
              '${tester.getRect(find.text('Player 10'))}',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    },
  );
}
