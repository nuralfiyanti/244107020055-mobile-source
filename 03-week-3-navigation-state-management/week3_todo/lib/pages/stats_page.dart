// lib/pages/stats_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// ConsumerWidget: widget yang bisa membaca provider lewat parameter `ref`.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch DI DALAM build → widget otomatis rebuild saat state berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Kondisi loading: tampilkan spinner di tengah layar.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Kondisi error: tampilkan pesan + tombol retry.
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $err'),
              const SizedBox(height: 12),
              FilledButton(
                // ref.read DI DALAM callback → cukup panggil method sekali,
                // tidak perlu berlangganan perubahan di sini.
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),

        // Kondisi success: tampilkan 3 item dalam ListView.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(stats[index].label),
            trailing: Text('${stats[index].value}'),
          ),
        ),
      ),
    );
  }
}