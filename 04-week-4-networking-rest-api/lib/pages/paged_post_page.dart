import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import 'widgets/post_tile.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  void _maybeLoadMore() {
    if (!_controller.hasClients) return;
    if (ref.read(pagedPostsProvider).error != null) return;
    final pos = _controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());

    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(state.error!)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(pagedPostsProvider.notifier).loadFirstPage(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Paged'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Non-paged version',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (!state.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Semua data termuat.')),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.items[index];
          return PostTile(
            post: post,
            showBody: false,
            onTap: () => context.go('/post/${post.id}'),
          );
        },
      ),
    );
  }
}