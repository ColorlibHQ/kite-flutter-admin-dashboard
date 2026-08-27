// A one-screen dashboard, which is the shortest honest demonstration of what
// this package is for. Run with: flutter run -d chrome
import 'package:flutter/widgets.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:kite_ui/shadcn.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => ShadApp(
    title: 'kite_ui example',
    theme: ShadThemeData(
      colorScheme: const ShadSlateColorScheme.light(),
      brightness: Brightness.light,
    ),
    darkTheme: ShadThemeData(
      colorScheme: const ShadSlateColorScheme.dark(),
      brightness: Brightness.dark,
    ),
    home: const DashboardScreen(),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _revenue = <double>[
    12,
    14,
    13,
    17,
    16,
    19,
    22,
    21,
    25,
    27,
    26,
    31,
  ];

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    return Container(
      color: c.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KiteSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Height is explicit, so these stay the same size on a phone and
              // on a 32-inch monitor. That is the whole reason KiteStatGrid
              // exists instead of a GridView with a childAspectRatio.
              KiteStatGrid(
                height: 132,
                children: const [
                  KiteStat(
                    label: 'Revenue',
                    value: r'$284,120',
                    delta: '+12.4%',
                    deltaTone: KiteTone.success,
                  ),
                  KiteStat(
                    label: 'Orders',
                    value: '3,412',
                    delta: '+4.1%',
                    deltaTone: KiteTone.success,
                  ),
                  KiteStat(
                    label: 'Refund rate',
                    value: '1.4%',
                    delta: '-0.3%',
                    deltaTone: KiteTone.danger,
                  ),
                ],
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteCard(
                title: 'Revenue',
                trailing: const KiteBadge('Last 60 days'),
                child: const SizedBox(
                  height: 220,
                  child: KiteSparkline(values: _revenue),
                ),
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteCard(
                title: 'Traffic by channel',
                child: KiteDonut(
                  centerLabel: 'Sessions',
                  centerValue: '48,210',
                  slices: [
                    KiteSlice(label: 'Direct', value: 42, color: c.primary),
                    KiteSlice(label: 'Organic', value: 27, color: c.secondary),
                    KiteSlice(label: 'Referral', value: 18, color: c.muted),
                    KiteSlice(label: 'Email', value: 13, color: c.accent),
                  ],
                ),
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteButton(onPressed: () {}, child: const Text('Export report')),
            ],
          ),
        ),
      ),
    );
  }
}
