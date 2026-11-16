import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/features/apps/calendar_screen.dart';

import 'accessibility_test.dart' show pumpScreen;

void main() {
  testWidgets('calendar shows its agenda beside the schedule on desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpScreen(tester, const CalendarScreen());

    expect(tester.takeException(), isNull);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Quarterly inventory review'), findsOneWidget);
  });
}
