import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

/// Implementasi repository konkret untuk fitur Notes dengan local search cache.
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

  /// Cache hasil pencarian in-memory (normalized query -> hasil filter).
  static const int _maxCacheEntries = 50;
  final Map<String, List<Note>> _searchCache = {};

  @override
  Future<(List<Note>?, Failure?)> searchNotesByTitle(String query) async {
    try {
      if (query.isEmpty) {
        return (List<Note>.from(_localDatabase), null);
      }

      final normalizedQuery = query.toLowerCase();
      final cached = _searchCache[normalizedQuery];
      if (cached != null) {
        return (List<Note>.from(cached), null);
      }

      // Case-insensitive filtering
      final results = _localDatabase.where((note) {
        return note.title.toLowerCase().contains(normalizedQuery);
      }).toList();

      if (_searchCache.length >= _maxCacheEntries) {
        _searchCache.remove(_searchCache.keys.first);
      }
      _searchCache[normalizedQuery] = results;
      return (List<Note>.from(results), null);
    } catch (e) {
      return (null, CacheFailure('Gagal memuat catatan: ${e.toString()}'));
    }
  }
}
