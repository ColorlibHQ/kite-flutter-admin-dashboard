import 'dart:convert';

class AuthConfig {
  const AuthConfig({
    this.url = '',
    this.publicKey = '',
    this.redirectUrl = '',
    this.apiUrl = '',
    this.demo = false,
  });
  static const environment = AuthConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    publicKey: String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
    ),
    redirectUrl: String.fromEnvironment('KITE_AUTH_REDIRECT_URL'),
    apiUrl: String.fromEnvironment('KITE_API_URL'),
    demo: bool.fromEnvironment('KITE_DEMO'),
  );
  final String url;
  final String publicKey;
  final String redirectUrl;
  final String apiUrl;
  final bool demo;
  bool get isProduction =>
      url.isNotEmpty || publicKey.isNotEmpty || redirectUrl.isNotEmpty;

  void validate() {
    if (!isProduction) {
      if (apiUrl.isNotEmpty && !demo) {
        throw StateError(
          'A remote API requires production authentication or explicit KITE_DEMO=true.',
        );
      }
      return;
    }
    if (demo) {
      throw StateError(
        'KITE_DEMO cannot be combined with production authentication.',
      );
    }
    if (apiUrl.isNotEmpty) {
      final api = Uri.tryParse(apiUrl);
      if (api == null ||
          !_isHttp(api) ||
          api.userInfo.isNotEmpty ||
          api.hasQuery ||
          api.hasFragment) {
        throw StateError(
          'Production APIs must use HTTPS, or HTTP on loopback for local development.',
        );
      }
    }
    final project = Uri.tryParse(url);
    if (project == null ||
        !_isHttp(project) ||
        project.userInfo.isNotEmpty ||
        project.hasQuery ||
        project.hasFragment ||
        publicKey.isEmpty) {
      throw StateError('Set SUPABASE_URL and a public SUPABASE_ANON_KEY.');
    }
    // JWT service-role keys must never be distributed. Publishable keys use
    // sb_publishable_*, legacy anon keys are validated by the SDK/server.
    if (publicKey.startsWith('sb_secret_')) {
      throw StateError('Use a public client key.');
    }
    if (!publicKey.startsWith('sb_publishable_')) {
      try {
        final claims = jsonDecode(
          utf8.decode(
            base64Url.decode(base64Url.normalize(publicKey.split('.')[1])),
          ),
        );
        if (claims is! Map<String, dynamic> || claims['role'] != 'anon') {
          throw const FormatException();
        }
      } on Object {
        throw StateError(
          'Use a publishable key or legacy anon key, never a server secret.',
        );
      }
    }
    final redirect = Uri.tryParse(redirectUrl);
    if (redirect == null ||
        redirect.userInfo.isNotEmpty ||
        redirect.hasQuery ||
        redirect.hasFragment ||
        !redirect.path.endsWith('/auth/callback') ||
        !(_isHttp(redirect) ||
            (redirect.scheme == 'kite' && redirect.host == 'login'))) {
      throw StateError(
        'Configure KITE_AUTH_REDIRECT_URL with an allowed /auth/callback URL.',
      );
    }
  }

  bool _isHttp(Uri uri) =>
      uri.host.isNotEmpty &&
      (uri.scheme == 'https' ||
          (uri.scheme == 'http' &&
              const {'localhost', '127.0.0.1', '::1'}.contains(uri.host)));
}
