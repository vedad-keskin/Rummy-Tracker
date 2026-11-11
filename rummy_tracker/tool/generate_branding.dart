import 'dart:convert';
import 'dart:io';

// Reuse the image library already supplied by flutter_launcher_icons.
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

const background = 0x101B2D;
const densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

img.Image tile(img.Image logo, int size, double scale, {bool opaque = true}) {
  final canvas = img.Image(
    width: size,
    height: size,
    numChannels: opaque ? 3 : 4,
  );
  if (opaque) {
    img.fill(canvas, color: img.ColorRgb8(16, 27, 45));
  }
  final mark = img.copyResize(
    logo,
    width: (size * scale).round(),
    interpolation: img.Interpolation.average,
  );
  return img.compositeImage(
    canvas,
    mark,
    dstX: (size - mark.width) ~/ 2,
    dstY: (size - mark.height) ~/ 2,
  );
}

void save(String path, img.Image image) {
  File(path).parent.createSync(recursive: true);
  File(path).writeAsBytesSync(img.encodePng(image));
}

img.Image checkImage(String path, int size, {bool opaque = false}) {
  final image = img.decodeImage(File(path).readAsBytesSync());
  if (image == null ||
      image.width != size ||
      image.height != size ||
      (opaque && image.any((p) => p.a != 255))) {
    throw StateError('Invalid image: $path');
  }
  return image;
}

void checkBranding() {
  for (final entry in densities.entries) {
    final root = 'android/app/src/main/res';
    checkImage(
      '$root/mipmap-${entry.key}/ic_launcher.png',
      (48 * entry.value).round(),
      opaque: true,
    );
    checkImage(
      '$root/drawable-${entry.key}/launch_logo.png',
      (192 * entry.value).round(),
    );
    final foreground = checkImage(
      '$root/drawable-${entry.key}/ic_launcher_foreground.png',
      (108 * entry.value).round(),
    );
    // Android guarantees the central 66dp circle of each 108dp foreground.
    final radius = foreground.width * 33 / 108;
    for (final p in foreground) {
      final dx = p.x + 0.5 - foreground.width / 2;
      final dy = p.y + 0.5 - foreground.height / 2;
      if (p.a > 8 && dx * dx + dy * dy > radius * radius) {
        throw StateError(
          'Adaptive artwork exceeds the safe zone: ${entry.key}',
        );
      }
    }
  }
  for (final platform in ['ios', 'macos']) {
    final root = '$platform/Runner/Assets.xcassets/AppIcon.appiconset';
    final catalog =
        jsonDecode(File('$root/Contents.json').readAsStringSync())
            as Map<String, dynamic>;
    for (final entry in catalog['images'] as List) {
      final size =
          (double.parse((entry['size'] as String).split('x').first) *
                  double.parse((entry['scale'] as String).replaceAll('x', '')))
              .round();
      final image = checkImage(
        '$root/${entry['filename']}',
        size,
        opaque: true,
      );
      if (platform == 'ios' && image.hasAlpha) {
        throw StateError('iOS icon still has an alpha channel');
      }
    }
  }
  for (final size in [192, 512]) {
    checkImage('web/icons/Icon-$size.png', size, opaque: true);
    final maskable = checkImage(
      'web/icons/Icon-maskable-$size.png',
      size,
      opaque: true,
    );
    for (final p in maskable) {
      final dx = p.x + 0.5 - size / 2;
      final dy = p.y + 0.5 - size / 2;
      final rgb = (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
      if (rgb != background && dx * dx + dy * dy > size * size * 0.16) {
        throw StateError('Web maskable artwork exceeds its safe circle');
      }
    }
  }
  final playIcon = checkImage(
    'store_assets/google-play-icon.png',
    512,
    opaque: true,
  );
  if (!playIcon.hasAlpha ||
      File('store_assets/google-play-icon.png').lengthSync() > 1024 * 1024) {
    throw StateError('Google Play icon must be 32-bit PNG under 1MB');
  }
  if (checkImage(
    'store_assets/app-store-icon.png',
    1024,
    opaque: true,
  ).hasAlpha) {
    throw StateError('App Store icon must have no alpha channel');
  }
  checkImage('../rummy-tracker-web/public/favicon.png', 64, opaque: true);
  checkImage(
    '../rummy-tracker-web/public/apple-touch-icon.png',
    180,
    opaque: true,
  );
  stdout.writeln(
    'Branding checks passed: icon sizes, opacity and mask safe zones.',
  );
}

Future<void> main(List<String> arguments) async {
  Directory.current = File.fromUri(Platform.script).parent.parent;
  if (arguments.isNotEmpty) {
    if (arguments.length != 1 || arguments.single != '--check') {
      throw ArgumentError(
        'Usage: dart run tool/generate_branding.dart [--check]',
      );
    }
    checkBranding();
    return;
  }
  final logo = img.decodePng(
    File('assets/images/logo_transparent.png').readAsBytesSync(),
  );
  if (logo == null ||
      logo.width != logo.height ||
      logo.width < 1024 ||
      !logo.hasAlpha) {
    throw StateError(
      'Expected a square transparent master logo of at least 1024px.',
    );
  }
  final icon = tile(logo, 1024, 0.82);
  save('assets/branding/launcher.png', icon);
  save(
    'assets/branding/launcher_foreground.png',
    tile(logo, 1024, 0.54, opaque: false),
  );
  // Run the CLI to completion: version 0.13 schedules Android writes asynchronously.
  final generator = await Process.start(Platform.resolvedExecutable, [
    'run',
    'flutter_launcher_icons',
    '-f',
    'pubspec.yaml',
  ], mode: ProcessStartMode.inheritStdio);
  if (await generator.exitCode != 0) {
    throw StateError('Launcher icon generation failed.');
  }
  for (final entry in densities.entries) {
    save(
      'android/app/src/main/res/drawable-${entry.key}/launch_logo.png',
      img.copyResize(
        logo,
        width: (192 * entry.value).round(),
        interpolation: img.Interpolation.average,
      ),
    );
  }
  for (final scale in [1, 2, 3]) {
    final suffix = scale == 1 ? '' : '@${scale}x';
    save(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
      img.copyResize(
        logo,
        width: 192 * scale,
        interpolation: img.Interpolation.average,
      ),
    );
  }
  for (final size in [192, 512]) {
    save('web/icons/Icon-maskable-$size.png', tile(logo, size, 0.70));
  }
  save(
    'store_assets/google-play-icon.png',
    tile(logo, 512, 0.82).convert(numChannels: 4),
  );
  save('store_assets/app-store-icon.png', icon);
  File(
    'assets/images/logo.jpg',
  ).writeAsBytesSync(img.encodeJpg(icon, quality: 95));
  File(
    'assets/images/logo_transparent.png',
  ).copySync('../rummy-tracker-web/public/logo.png');
  save('../rummy-tracker-web/public/favicon.png', tile(logo, 64, 0.82));
  save(
    '../rummy-tracker-web/public/apple-touch-icon.png',
    tile(logo, 180, 0.82),
  );
  File(
    'windows/runner/resources/app_icon.ico',
  ).copySync('../rummy-tracker-web/public/favicon.ico');
  checkBranding();
}
