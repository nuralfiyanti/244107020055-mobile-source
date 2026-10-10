import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner dirty
          dirtyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (count) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: count > 0
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              child: Row(
                children: [
                  Icon(
                    count > 0 ? Icons.cloud_off : Icons.cloud_done,
                    color: count > 0 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      count > 0
                          ? '$count catatan belum tersinkron'
                          : 'Semua catatan sudah tersinkron',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Daftar catatan
          Expanded(
            child: notesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(child: Text('Belum ada catatan.'));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final note = notes[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(note.id.toString()),
                        ),
                        title: Text(note.title),
                        subtitle: Row(
                          children: [
                            Icon(
                              note.dirty
                                  ? Icons.cloud_off
                                  : Icons.cloud_done,
                              size: 14,
                              color: note.dirty
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.dirty
                                  ? 'Belum tersinkron'
                                  : 'Sudah tersinkron',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final repo =
                                ref.read(noteRepositoryProvider);
                            await repo.deleteNote(note.id!);
                            ref.invalidate(notesProvider);
                            ref.invalidate(dirtyCountProvider);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repo = ref.read(noteRepositoryProvider);
          await repo.addNote(
            title: 'Catatan ${DateTime.now().second}',
            body: 'deadline 1 minggu',
          );
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyCountProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}