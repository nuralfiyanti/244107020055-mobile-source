import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsCacheProvider);
    final isOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Cache'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(postsCacheProvider.notifier)
                  .refreshPostsInBackground();
            },
          ),
        ],
      ),
      body: Column(
        children: [
     
          SwitchListTile(
            title: const Text('Simulasi Offline'),
            subtitle: Text(
              isOffline ? 'Aktif — tidak fetch jaringan' : 'Nonaktif',
            ),
            value: isOffline,
            onChanged: (_) =>
                ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          Expanded(
            child: postsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('Belum ada cache. Tekan refresh.'),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(post.id.toString()),
                      ),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}