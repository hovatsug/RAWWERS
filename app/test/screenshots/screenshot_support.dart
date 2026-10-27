// Shared by the screenshot harnesses: real fonts, and a PNG of what was pumped.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the PNGs go. Null skips every screenshot test.
final screenshotDir = Platform.environment['SCREENSHOT_DIR'];

/// Archivo and the Material icons, so the shots show glyphs, not boxes.
Future<void> loadScreenshotFonts() async {
  final archivo = FontLoader('Archivo')..addFont(rootBundle.load('assets/fonts/Archivo-Variable.ttf'));
  await archivo.load();
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

/// Pumps [app] at a phone's size (390x844 points, 3x) and writes it to
/// `$SCREENSHOT_DIR/$name.png`.
Future<void> shoot(WidgetTester tester, String name, Widget app, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Tests draw elevation as a solid black outline unless told otherwise.
  // Put back before the test ends: the framework checks it was.
  debugDisableShadows = false;
  try {
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: app));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$screenshotDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  } finally {
    debugDisableShadows = true;
  }
}
