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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Token perangkat: ${state.maskedToken ?? 'Belum tersedia'}',
                ),
              ),
              IconButton(
                onPressed: state.maskedToken == null
                    ? null
                    : controller.copyToken,
                icon: const Icon(Icons.copy),
                tooltip: 'Salin token untuk Firebase Console',
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.started ? controller.resetToken : controller.start,
            icon: const Icon(Icons.refresh),
            label: Text(state.started ? 'Reset token' : 'Mulai FCM'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: state.started
                ? controller.unsubscribeFromCampusTopic
                : null,
            icon: const Icon(Icons.notifications_off_outlined),
            label: const Text('Berhenti dari topik kampus'),
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
