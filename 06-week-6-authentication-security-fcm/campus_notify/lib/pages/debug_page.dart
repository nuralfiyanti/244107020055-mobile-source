import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/push_provider.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pushControllerProvider);
    final controller = ref.read(pushControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Izin notifikasi: ${state.permission}'),
          const SizedBox(height: 16),
          Text('Token perangkat: ${state.maskedToken ?? 'Belum tersedia'}'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.started ? controller.resetToken : controller.start,
            icon: const Icon(Icons.refresh),
            label: Text(state.started ? 'Reset token' : 'Mulai FCM'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Log kejadian',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final log in state.logs) ListTile(
            dense: true,
            leading: const Icon(Icons.info_outline),
            title: Text(log),
          ),
        ],
      ),
    );
  }
}
