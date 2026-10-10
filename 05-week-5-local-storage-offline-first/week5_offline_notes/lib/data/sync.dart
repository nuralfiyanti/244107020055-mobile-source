import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'api_client.dart';
import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

// Dio Provider 
final dioProvider = Provider<Dio>((ref) => createDio());

// Cache Posts 
Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map((row) {
    final payload = row['payload'] as String? ?? '{}';
    final json = Map<String, dynamic>.from(
      (payload.isEmpty ? {} : jsonDecode(payload)) as Map,
    );
    return Post.fromJson(json);
  }).toList();
}

Future<void> saveCachedPosts(List<Post> posts) async {
  final db = await openNotesDb();
  final batch = db.batch();
  for (final post in posts) {
    batch.insert(
      'cached_posts',
      {
        'id': post.id,
        'payload': jsonEncode(post.toJson()),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit(noResult: true);
}

// Posts Cache Notifier 
class PostsCacheNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    return _loadCacheFirst();
  }

  Future<List<Post>> _loadCacheFirst() async {
    final cached = await readCachedPosts();
    unawaited(refreshPostsInBackground());
    return cached;
  }

  Future<void> refreshPostsInBackground() async {
    if (ref.read(forceOfflineProvider)) return;
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<List>('/posts');
      final data = response.data ?? [];
      final posts = data
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList();
      await saveCachedPosts(posts);
      state = AsyncData(posts);
    } catch (_) {}
  }
}

final postsCacheProvider =
    AsyncNotifierProvider<PostsCacheNotifier, List<Post>>(
  PostsCacheNotifier.new,
  retry: (retryCount, error) => null,
);

// Sync Notes
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

// Force Offline Toggle 
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);