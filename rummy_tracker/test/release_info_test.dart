import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/components/team_credits_dialog.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';
import 'package:rummy_tracker/main.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Rummy Tracker',
      packageName: 'com.rummy.tracker',
      version: '9.8.7',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  testWidgets(
    'Credits require a hold and show only the installed version below Close',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final language = tester
          .element(find.byType(MainMenuScreen))
          .read<LanguageService>();
      final credits = find.byKey(const ValueKey('app-credits'));
      expect(tester.getSize(credits).shortestSide, greaterThanOrEqualTo(48));
      expect(find.byKey(const ValueKey('privacy-policy')), findsNothing);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsNothing);
      expect(find.byTooltip('About Rummy Tracker'), findsNothing);
      await tester.tap(credits);
      await tester.pumpAndSettle();
      expect(find.byType(TeamCreditsDialog), findsNothing);

      await tester.longPress(credits);
      await tester.pumpAndSettle();
      expect(find.text('v 9.8.7'), findsOneWidget);
      expect(find.textContaining('Build'), findsNothing);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('app-version'))).dy,
        greaterThan(
          tester.getBottomLeft(find.widgetWithText(TextButton, 'CLOSE')).dy,
        ),
      );
      expect(tester.takeException(), isNull);

      await language.setLanguage('bs');
      await tester.pumpAndSettle();
      expect(find.text('v 9.8.7'), findsOneWidget);
      await tester.tap(find.text('ZATVORI'));
      await tester.pumpAndSettle();

      expect(find.byType(TeamCreditsDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final (size, textScale) in [
    (const Size(360, 800), 1.0),
    (const Size(640, 360), 1.0),
    (const Size(768, 1024), 1.0),
    (const Size(360, 640), 2.0),
  ]) {
    testWidgets('Credits move, settle and fit at $size with text $textScale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const ValueKey('app-credits')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final ace = find.byKey(const ValueKey('credits-card-0'));
      final entering = tester.getCenter(ace);
      await tester.pump(const Duration(milliseconds: 250));
      expect((tester.getCenter(ace) - entering).distance, greaterThan(16));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 50),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      final settled = tester.getCenter(ace);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getCenter(ace), settled);
      expect(find.byType(TeamCreditsDialog), findsOneWidget);

      final close = find.widgetWithText(TextButton, 'CLOSE');
      final footer = tester.getRect(close);
      expect(tester.getSize(close).height, greaterThanOrEqualTo(48));
      expect(close.hitTestable(), findsOneWidget);
      if (textScale == 1) {
        expect(
          tester.getRect(find.text('Vedad Keskin')).bottom,
          lessThan(footer.top),
        );
      }
      expect(
        tester.getRect(find.byKey(const ValueKey('app-version'))).bottom,
        lessThanOrEqualTo(size.height - 24),
      );
      await tester.ensureVisible(find.text('Vedad Keskin'));
      await tester.pumpAndSettle();
      expect(tester.getRect(close), footer);
      expect(
        tester.getRect(find.text('Vedad Keskin')).bottom,
        lessThan(footer.top),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(TeamCreditsDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Reduced-motion credits are still; Close and Back dismiss during entry',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final trigger = find.byKey(const ValueKey('app-credits'));
      await tester.longPress(trigger);
      await tester.pump();
      final ace = find.byKey(const ValueKey('credits-card-0'));
      final position = tester.getCenter(ace);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.getCenter(ace), position);
      expect(find.byKey(const ValueKey('credits-light-trails')), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(TeamCreditsDialog), findsNothing);

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      await tester.pump();
      for (final useBack in [false, true]) {
        await tester.longPress(trigger);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        if (useBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.widgetWithText(TextButton, 'CLOSE'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(TeamCreditsDialog), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
