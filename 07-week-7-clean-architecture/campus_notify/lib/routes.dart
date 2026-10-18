class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';

  /// Route pengumuman: `/pengumuman/:id`
  static const pengumuman = '/pengumuman';
  static String pengumumanById(Object id) => '$pengumuman/$id';

  /// Ekstrak route dari payload FCM (`data.route`).
  static String? fromFcmData(Map<String, dynamic> data) {
    final raw = data['route'];
    if (raw is! String || raw.isEmpty) return null;
    return raw.startsWith('/') ? raw : '/$raw';
  }
}