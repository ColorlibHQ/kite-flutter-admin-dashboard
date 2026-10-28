import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/l10n/locale_controller.dart';
import 'package:kite/core/preferences/preferences_store.dart';
import 'package:kite/core/theme/app_theme.dart';

void main() {
  test(
    'theme, accent and locale survive a fresh application container',
    () async {
      final disk = <String, String>{};
      final store = PreferencesStore(
        persist: (key, value) async => disk[key] = value,
      );
      final first = ProviderContainer(
        overrides: [preferencesStoreProvider.overrideWithValue(store)],
      );
      first.read(themeProvider.notifier).setMode(ThemeMode.dark);
      first.read(themeProvider.notifier).setAccent(KiteAccent.violet);
      first.read(localeProvider.notifier).set(KiteLocale.ar);
      await store.flush();
      first.dispose();
      final restored = PreferencesStore(initial: disk);
      final second = ProviderContainer(
        overrides: [preferencesStoreProvider.overrideWithValue(restored)],
      );
      expect(second.read(themeProvider).mode, ThemeMode.dark);
      expect(second.read(themeProvider).accent, KiteAccent.violet);
      expect(second.read(localeProvider), KiteLocale.ar);
      second.dispose();
      store.dispose();
      restored.dispose();
    },
  );

  test('unknown stored values fall back to supported defaults', () {
    final store = PreferencesStore(
      initial: {'theme.mode': 'bad', 'theme.accent': 'pink', 'locale': 'xx'},
    );
    final container = ProviderContainer(
      overrides: [preferencesStoreProvider.overrideWithValue(store)],
    );
    expect(container.read(themeProvider).mode, ThemeMode.system);
    expect(container.read(themeProvider).accent, KiteAccent.slate);
    expect(container.read(localeProvider), KiteLocale.en);
    container.dispose();
    store.dispose();
  });

  test('rapid writes preserve the latest selection', () async {
    final writes = <String>[];
    final store = PreferencesStore(
      persist: (key, value) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        writes.add(value);
      },
    );
    store.set('locale', 'es');
    store.set('locale', 'ja');
    store.set('locale', 'ar');
    await store.flush();
    expect(writes, ['es', 'ja', 'ar']);
    expect(store.read('locale'), 'ar');
    store.dispose();
  });

  test(
    'failed writes are reported and retried without losing other settings',
    () async {
      var fail = true;
      final disk = <String, String>{};
      final store = PreferencesStore(
        persist: (key, value) async {
          if (fail && key == 'locale') throw StateError('storage unavailable');
          disk[key] = value;
        },
      );
      store.set('locale', 'fr');
      store.set('theme.mode', 'dark');
      await store.flush();
      expect(store.saveFailed, isTrue);
      expect(store.read('locale'), 'fr');
      fail = false;
      store.retry();
      await store.flush();
      expect(store.saveFailed, isFalse);
      expect(disk, {'locale': 'fr', 'theme.mode': 'dark'});
      store.dispose();
    },
  );
}
