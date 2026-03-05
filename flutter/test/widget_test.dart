import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers_flutter/app/app.dart';

void main() {
  test('RawwersApp exists and is a widget', () {
    const app = RawwersApp();
    expect(app, isA<Widget>());
  });
}
