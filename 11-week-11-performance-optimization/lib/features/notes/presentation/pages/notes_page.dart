import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(notesListProvider.notifier).search(value);
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(notesListProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah'),
      ),
      body: Column(
        children: [
          _NotesSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _onClearSearch,
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final notesAsync = ref.watch(notesListProvider);
                return notesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Terjadi kesalahan: $error')),
                  data: (notes) => notes.isEmpty
                      ? const _NotesEmptyState()
                      : _NotesListView(notes: notes),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _NotesSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            key: const Key('notes_search_field'),
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Cari judul catatan...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}

class _NotesEmptyState extends StatelessWidget {
  const _NotesEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('notes_empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Catatan tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesListView extends StatelessWidget {
  final List<Note> notes;

  const _NotesListView({required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('notes_list_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) => _NoteTile(note: notes[index]),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final Note note;

  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(
        note.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: const CircleAvatar(child: Icon(Icons.note_alt_outlined)),
    );
  }
}
