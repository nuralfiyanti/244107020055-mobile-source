import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/push_provider.dart';
import '../../../../routes.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../providers/auth_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _announcementIds = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(pushControllerProvider.notifier).start(),
    );
  }

  void _openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const NotesPage()),
    );
  }

  void _openChat() => context.push(AppRoutes.chat);

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
      body: Column(
        children: [
          _HomeQuickActions(
            onOpenNotes: _openNotes,
            onOpenChat: _openChat,
          ),
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text('Sesi aktif'),
            subtitle: Text('Token tersimpan di secure storage'),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _announcementIds.length,
              itemBuilder: (context, index) =>
                  _AnnouncementTile(id: _announcementIds[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickActions extends StatelessWidget {
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenChat;

  const _HomeQuickActions({
    required this.onOpenNotes,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: onOpenNotes,
            icon: const Icon(Icons.search),
            label: const Text('Buka Catatan'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FilledButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text('Asisten Kampus AI'),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final int id;

  const _AnnouncementTile({required this.id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.campaign),
      title: Text('Pengumuman $id'),
      onTap: () => context.push('/pengumuman/$id'),
    );
  }
}
