import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

/// Halaman detail post. State diambil dari `postListProvider` yang
/// sudah dimuat. Kalau post tidak ditemukan di list (misal deep link),
/// tampilkan pesan agar user kembali ke daftar.
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              friendlyErrorMessage(err),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (posts) {
          final Post? post = posts.cast<Post?>().firstWhere(
                (p) => p?.id == postId,
                orElse: () => null,
              );

          if (post == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Post tidak ditemukan.\nKembali ke daftar untuk memuat ulang.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(postListProvider),
                      child: const Text('Muat ulang daftar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Post ID: ${post.id} · User ID: ${post.userId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(post.body),
              ],
            ),
          );
        },
      ),
    );
  }
}