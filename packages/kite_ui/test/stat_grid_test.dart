import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/kite_ui.dart';

void main() {
  Future<void> renderGrid(
    WidgetTester tester, {
    required double width,
    int count = 3,
  }) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: KiteStatGrid(
            height: 80,
            spacing: 16,
            minTileWidth: 200,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(key: ValueKey('tile-$i')),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('tiles keep their height when the viewport widens', (
    tester,
  ) async {
    await renderGrid(tester, width: 700);
    final first = find.byKey(const ValueKey('tile-0'));
    final last = find.byKey(const ValueKey('tile-2'));
    expect(tester.getSize(first).height, 80);
    expect(tester.getTopLeft(first).dy, tester.getTopLeft(last).dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layouts wrap without squeezing tiles', (tester) async {
    await renderGrid(tester, width: 240);
    final first = find.byKey(const ValueKey('tile-0'));
    final second = find.byKey(const ValueKey('tile-1'));
    expect(tester.getSize(first), const Size(240, 80));
    expect(tester.getTopLeft(second).dy - tester.getTopLeft(first).dy, 96);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an incomplete final row keeps the column widths', (
    tester,
  ) async {
    await renderGrid(tester, width: 500);
    final first = find.byKey(const ValueKey('tile-0'));
    final last = find.byKey(const ValueKey('tile-2'));
    expect(tester.getSize(first).width, 242);
    expect(tester.getSize(last).width, tester.getSize(first).width);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty grid renders without an exception', (tester) async {
    await renderGrid(tester, width: 500, count: 0);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(KiteStatGrid)).height, 0);
  });
}
