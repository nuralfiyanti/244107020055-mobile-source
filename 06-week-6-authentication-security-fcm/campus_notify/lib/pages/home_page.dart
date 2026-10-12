import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text('Sesi aktif'),
            subtitle: Text('Token tersimpan di secure storage'),
          ),
          const Divider(),
          for (final id in [1, 2, 3])
            ListTile(
              leading: const Icon(Icons.campaign),
              title: Text('Pengumuman $id'),
              onTap: () => context.push('/pengumuman/$id'),
            ),
        ],
      ),
    );
  }
}