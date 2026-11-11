import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/background.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Credits use installed version; privacy opens externally or shows URL',
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

      final calls = <MethodCall>[];
      var browserAvailable = true;
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return browserAvailable;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );

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
      await tester.tap(find.byKey(const ValueKey('app-credits')));
      await tester.pumpAndSettle();
      expect(find.text('Version 9.8.7 · Build 42'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await language.setLanguage('bs');
      await tester.pumpAndSettle();
      expect(find.text('Verzija 9.8.7 · Izdanje 42'), findsOneWidget);
      await tester.tap(find.text('ZATVORI'));
      await tester.pumpAndSettle();

      final privacy = find.byKey(const ValueKey('privacy-policy'));
      expect(tester.getSize(privacy).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(privacy);
      await tester.pumpAndSettle();
      expect(calls.single.method, 'launch');
      expect(
        calls.single.arguments['url'],
        'https://rummy-tracker-web.vercel.app/privacy',
      );
      expect(calls.single.arguments['useWebView'], isFalse);
      expect(calls.single.arguments['useSafariVC'], isFalse);

      browserAvailable = false;
      await tester.tap(privacy);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      expect(
        find.textContaining('https://rummy-tracker-web.vercel.app/privacy'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
