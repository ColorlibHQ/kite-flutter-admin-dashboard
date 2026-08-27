import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean paths instead of Flutter's default hash URLs: /orders/10004 rather
  // than /#/orders/10004. Detail pages are only addressable — linkable to a
  // colleague, bookmarkable — if the URL looks like a URL.
  //
  // Requires the host to serve index.html for unknown paths. tools/serve.mjs
  // does; so do Cloudflare Pages, Netlify and Vercel by default.
  usePathUrlStrategy();

  runApp(const ProviderScope(child: KiteApp()));
}
