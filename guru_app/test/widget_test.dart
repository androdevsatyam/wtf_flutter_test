import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/src/app/guru_app.dart';

void main() {
  testWidgets('App renders MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GuruApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
