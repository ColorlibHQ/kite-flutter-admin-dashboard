import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive display preferences only. Auth tokens use separate storage.
class PreferencesStore extends ChangeNotifier {
  PreferencesStore({Map<String, String> initial = const {}, this.persist})
    : _values = {...initial};

  static const keys = {'theme.mode', 'theme.accent', 'locale'};
  final Map<String, String> _values;
  final Set<String> _dirty = {};
  final Future<void> Function(String, String)? persist;
  Future<void> _pending = Future<void>.value();
  bool _disposed = false;
  bool get saveFailed => _dirty.isNotEmpty && _failed;
  bool _failed = false;

  static Future<PreferencesStore> load() async {
    final storage = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: keys),
    );
    return PreferencesStore(
      initial: {
        for (final key in keys)
          if (storage.get(key) case final String value) key: value,
      },
      persist: storage.setString,
    );
  }

  String? read(String key) => _values[key];

  /// Serializes writes so rapid changes cannot persist an older selection last.
  void set(String key, String value) {
    assert(keys.contains(key));
    _values[key] = value;
    _dirty.add(key);
    _enqueue(key, value);
  }

  void _enqueue(String key, String value) {
    _pending = _pending.then((_) async {
      try {
        await persist?.call(key, value);
        if (_values[key] == value) _dirty.remove(key);
        if (_dirty.isEmpty) _failed = false;
      } on Object {
        _failed = true;
      }
      if (!_disposed) notifyListeners();
    });
  }

  void retry() {
    for (final key in _dirty.toList()) {
      _enqueue(key, _values[key]!);
    }
  }

  Future<void> flush() => _pending;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  final store = PreferencesStore();
  ref.onDispose(store.dispose);
  return store;
});
