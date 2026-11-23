import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/push_provider.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../providers/auth_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(pushControllerProvider.notifier).start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug FCM',
            onPressed: () => context.push('/debug'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Tombol untuk masuk ke halaman Catatan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Buka Catatan'),
            ),
          ),
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