import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:kite_ui/shadcn.dart';

void main() {
  for (final direction in TextDirection.values) {
    for (final scale in [1.0, 2.0]) {
      for (final empty in [false, true]) {
        testWidgets(
          'input content is centered: $direction, $scale, empty=$empty',
          (tester) async {
            final controller = TextEditingController(
              text: empty ? '' : 'hello@example.com',
            );
            addTearDown(controller.dispose);
            await tester.pumpWidget(
              ShadApp(
                home: Scaffold(
                  body: Center(
                    child: MediaQuery(
                      data: MediaQueryData(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: Directionality(
                        textDirection: direction,
                        child: SizedBox(
                          width: 320,
                          child: KiteInput(
                            controller: controller,
                            placeholder: 'Email address',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final input = tester.getRect(find.byType(ShadInput));
            final content = tester.getRect(
              empty ? find.text('Email address') : find.byType(EditableText),
            );
            expect(content.center.dy, closeTo(input.center.dy, 1));
            expect(input.height, greaterThanOrEqualTo(48));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
