import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/app/app.dart';

void main() {
  testWidgets('application foundation renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('QO-100 TR'), findsOneWidget);
  });
}
