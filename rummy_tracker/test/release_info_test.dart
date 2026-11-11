import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/background.dart';
import 'package:rummy_tracker/components/team_credits_dialog.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Credits require a hold and show only the installed version below Close',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'Rummy Tracker',
        packageName: 'com.rummy.tracker',
        version: '9.8.7',
        buildNumber: '42',
        buildSignature: '',
      );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final language = LanguageService();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => language),
            ChangeNotifierProvider(create: (_) => BackgroundService()),
          ],
          child: const MaterialApp(home: MainMenuScreen()),
        ),
      );
      await tester.pumpAndSettle();
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
}
