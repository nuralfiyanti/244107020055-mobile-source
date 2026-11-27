import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

/// Implementasi repository konkret untuk fitur Notes.
class NotesRepositoryImpl implements NotesRepository {
  // Mock data in-memory yang merepresentasikan data lokal SQLite
  final List<Note> _localDatabase = [
    Note(
      id: '1',
      title: 'Tugas Mobile Programming',
      content: 'Mengerjakan Clean Architecture Week 9',
      updatedAt: DateTime.now(),
    ),
    Note(
      id: '2',
      title: 'Catatan Arsitektur Flutter',
      content: 'Feature-first presentation domain data',
      updatedAt: DateTime.now(),
    ),
    Note(
      id: '3',
      title: 'Belajar Riverpod StateNotifier',
      content: 'Pahami autoDispose dan family provider',
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<(List<Note>?, Failure?)> searchNotesByTitle(String query) async {
    try {
      if (query.isEmpty) {
        return (List<Note>.from(_localDatabase), null);
      }

      final normalizedQuery = query.toLowerCase();
      // Case-insensitive filtering
      final results = _localDatabase.where((note) {
        return note.title.toLowerCase().contains(normalizedQuery);
      }).toList();

      return (results, null);
    } catch (e) {
      return (null, CacheFailure('Gagal memuat catatan: ${e.toString()}'));
    }
  }
}