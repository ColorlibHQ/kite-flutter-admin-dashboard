import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native refresh tokens stay in the OS credential store, not display prefs.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage(this.key);
  final String key;
  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: key);
  @override
  Future<String?> accessToken() => _storage.read(key: key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: key, value: persistSessionString);
  @override
  Future<void> removePersistedSession() => _storage.delete(key: key);
}

/// PKCE verifiers are short-lived credentials too.
class SecurePKCEStorage extends GotrueAsyncStorage {
  SecurePKCEStorage(this.prefix);
  final String prefix;
  @override
  Future<String?> getItem({required String key}) =>
      SecureSessionStorage._storage.read(key: '$prefix.$key');
  @override
  Future<void> setItem({required String key, required String value}) =>
      SecureSessionStorage._storage.write(key: '$prefix.$key', value: value);
  @override
  Future<void> removeItem({required String key}) =>
      SecureSessionStorage._storage.delete(key: '$prefix.$key');
}
