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

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Terjadi kesalahan: $error')),
              data: (notes) => notes.isEmpty ? _buildEmptyState() : _buildNotesList(notes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        key: const Key('notes_search_field'),
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari judul catatan...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(notesListProvider.notifier).search('');
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          ref.read(notesListProvider.notifier).search(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      key: Key('notes_empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Catatan tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return ListView.separated(
      key: const Key('notes_list_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          leading: const CircleAvatar(child: Icon(Icons.note_alt_outlined)),
        );
      },
    );
  }
}
