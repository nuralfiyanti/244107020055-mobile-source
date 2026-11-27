import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak repository untuk fitur Notes.
abstract interface class NotesRepository {
  /// Mengambil daftar catatan berdasarkan kata kunci judul.
  Future<(List<Note>?, Failure?)> searchNotesByTitle(String query);
}