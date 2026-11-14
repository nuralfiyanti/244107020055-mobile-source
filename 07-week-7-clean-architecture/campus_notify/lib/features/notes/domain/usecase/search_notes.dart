import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Operasi bisnis pencarian catatan berdasarkan judul.
class SearchNotesUseCase {
  const SearchNotesUseCase(this._repository);

  final NotesRepository _repository;

  Future<(List<Note>?, Failure?)> call(String query) async {
    final sanitizedQuery = query.trim();
    return _repository.searchNotesByTitle(sanitizedQuery);
  }
}