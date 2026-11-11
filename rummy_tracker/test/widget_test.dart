import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rummy_tracker/background.dart';

import 'package:rummy_tracker/layouts/splash_screen.dart';
import 'package:rummy_tracker/main.dart';

void main() {
  final logo = find.image(
    const AssetImage('assets/images/logo_transparent.png'),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(640, 360),
    const Size(768, 1024),
  ]) {
    testWidgets(
      'Cards visibly move, frame the logo and reach the menu at $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);

        await tester.pumpWidget(const MyApp());
        await tester.pump();
        expect(logo, findsOneWidget);
        final safeRect = Rect.fromLTWH(0, 24, size.width, size.height - 48);
        await tester.pump(const Duration(milliseconds: 200));
        final entering = tester.getCenter(
          find.byKey(const ValueKey('intro-card-0')),
        );
        await tester.pump(const Duration(milliseconds: 400));
        final moved = tester.getCenter(
          find.byKey(const ValueKey('intro-card-0')),
        );
        expect((moved - entering).distance, greaterThan(40));
        await tester.pump(const Duration(milliseconds: 800));
        final logoRect = tester.getRect(logo);
        for (var index = 0; index < 4; index++) {
          final cardRect = tester.getRect(
            find.byKey(ValueKey('intro-card-$index')),
          );
          expect(
            cardRect.overlaps(logoRect),
            isFalse,
            reason: 'Card obscured by logo',
          );
          expect(safeRect.contains(cardRect.topLeft), isTrue);
          expect(safeRect.contains(cardRect.bottomRight), isTrue);
        }
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 180));
        expect(logo, findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 50),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 3),
        );
        expect(find.byType(SplashScreen), findsNothing);
        expect(logo, findsOneWidget);
        expect(find.text('PLAY NOW'), findsOneWidget);
        expect(find.text('PLAYERS'), findsOneWidget);
        expect(find.text('RANKING'), findsOneWidget);
        final backgroundButton = find.byKey(
          const ValueKey('change-background'),
        );
        expect(
          tester.getSize(backgroundButton).height,
          greaterThanOrEqualTo(48),
        );
        expect(
          tester.getRect(backgroundButton).bottom,
          lessThanOrEqualTo(safeRect.bottom),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('Reduced motion uses a brief fade without card or Hero motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    for (var index = 0; index < 4; index++) {
      expect(find.byKey(ValueKey('intro-card-$index')), findsNothing);
    }
    expect(
      tester.widget<HeroMode>(find.byType(HeroMode).first).enabled,
      isFalse,
    );
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('PLAY NOW'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('change-background')));
    await tester.pump();
    await tester.pump();
    expect(
      find.image(const AssetImage('assets/images/game_night.webp')),
      findsNothing,
    );
    expect(
      find.image(const AssetImage('assets/images/burgundy_club.webp')),
      findsOneWidget,
    );
    expect(logo, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Disposing the intro early leaves no delayed navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('PLAY NOW'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Background button cycles, applies to other screens and remembers the choice',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(
        find.image(const AssetImage('assets/images/game_night.webp')),
        findsOneWidget,
      );

      final button = find.byKey(const ValueKey('change-background'));
      expect(tester.widget(button), isA<IconButton>());
      expect(
        find.descendant(of: button, matching: find.byType(Text)),
        findsNothing,
      );
      expect(
        find.byTooltip('BACKGROUND: Game Night. Next background'),
        findsOneWidget,
      );

      var previousBackground = 'game_night';
      for (final (file, name) in [
        ('burgundy_club', 'Burgundy Club'),
        ('emerald_felt', 'Emerald Felt'),
        ('modern_midnight', 'Modern Midnight'),
        ('game_night', 'Game Night'),
        ('burgundy_club', 'Burgundy Club'),
      ]) {
        await tester.tap(find.byKey(const ValueKey('change-background')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        final incoming = find.image(AssetImage('assets/images/$file.webp'));
        expect(
          find.image(AssetImage('assets/images/$previousBackground.webp')),
          findsOneWidget,
        );
        expect(incoming, findsOneWidget);
        final fades = tester.widgetList<FadeTransition>(
          find.ancestor(of: incoming, matching: find.byType(FadeTransition)),
        );
        expect(
          fades.any((fade) => fade.opacity.value > 0 && fade.opacity.value < 1),
          isTrue,
        );
        await tester.pumpAndSettle();
        expect(
          find.image(AssetImage('assets/images/$previousBackground.webp')),
          findsNothing,
        );
        previousBackground = file;
        expect(
          find.image(AssetImage('assets/images/$file.webp')),
          findsOneWidget,
        );
        expect(
          find.byTooltip('BACKGROUND: $name. Next background'),
          findsOneWidget,
        );
      }
      await tester.tap(find.text('PLAYERS'));
      await tester.pumpAndSettle();
      expect(
        find.image(const AssetImage('assets/images/burgundy_club.webp')),
        findsOneWidget,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_background'), 5);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(
        find.image(const AssetImage('assets/images/burgundy_club.webp')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('Removed backgrounds fall back to the default', () async {
    SharedPreferences.setMockInitialValues({'app_background': 2});
    final backgrounds = BackgroundService();
    await Future<void>.delayed(Duration.zero);
    expect(backgrounds.assetPath, 'assets/images/game_night.webp');
    backgrounds.dispose();
  });
}
