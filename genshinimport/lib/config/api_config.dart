import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// ── PASTE URL RAILWAY DI SINI ─────────────────────────────
  /// Railway → klik service backend → Settings → Networking → Public URL
  /// Contoh: https://genshinimport-backend-production-a1b2.up.railway.app
  static const String _defaultRailwayHost = 'http://genshinimport-production.up.railway.app';

  /// Bisa override: flutter run --dart-define=API_URL=https://xxx.up.railway.app
  static const String railwayHost = String.fromEnvironment(
    'API_URL',
    defaultValue: _defaultRailwayHost,
  );

  /// `false` = Railway (production), `true` = localhost (development)
  static const bool useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);

  static const int localPort = 3007;

  static String get baseUrl {
    if (useLocal) {
      if (kIsWeb) return 'http://localhost:$localPort/api';
      if (Platform.isAndroid) return 'http://10.0.2.2:$localPort/api';
      return 'http://localhost:$localPort/api';
    }

    if (railwayHost.isEmpty) {
      throw Exception(
        'URL Railway belum diset.\n'
        'Buka lib/config/api_config.dart → isi _defaultRailwayHost',
      );
    }

    final host = railwayHost.endsWith('/')
        ? railwayHost.substring(0, railwayHost.length - 1)
        : railwayHost;
    return '$host/api';
  }
}
