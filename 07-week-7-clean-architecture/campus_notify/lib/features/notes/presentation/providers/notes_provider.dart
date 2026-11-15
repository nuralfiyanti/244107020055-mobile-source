import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecase/search_notes.dart';

// 1. Dependency Injection untuk Repository & Use Case
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
  return SearchNotesUseCase(ref.watch(notesRepositoryProvider));
});

// 2. Notifier Provider untuk Daftar Catatan
final notesListProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    // Ambil seluruh catatan saat inisialisasi awal (query kosong)
    return _search('');
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _search(query));
  }

  Future<List<Note>> _search(String query) async {
    final useCase = ref.read(searchNotesUseCaseProvider);
    final (notes, failure) = await useCase(query);

    if (failure != null) {
      throw Exception(failure.message);
    }

    return notes ?? [];
  }
}
