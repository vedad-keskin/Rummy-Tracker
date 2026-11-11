import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rummy_tracker/main.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(360, 640)]) {
    testWidgets('Logo loads on splash and home at $size', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final logo = find.image(
        const AssetImage('assets/images/logo_transparent.png'),
      );
      await tester.pumpWidget(const MyApp());
      expect(logo, findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 800));
      expect(logo, findsOneWidget);
      expect(find.text('PLAY NOW'), findsOneWidget);
      expect(find.text('PLAYERS'), findsOneWidget);
      expect(find.text('RANKING'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
