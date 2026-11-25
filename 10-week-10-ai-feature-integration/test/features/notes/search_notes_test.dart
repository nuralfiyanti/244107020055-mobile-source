import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:campus_notify/features/notes/domain/repositories/notes_repository.dart';
import 'package:campus_notify/features/notes/domain/usecase/search_notes.dart';

void main() {
  late NotesRepository repository;
  late SearchNotesUseCase useCase;

  setUp(() {
    repository = NotesRepositoryImpl();
    useCase = SearchNotesUseCase(repository);
  });

  group('SearchNotesUseCase & NotesRepository Tests', () {
    test(
      'Skenario Sukses: Pencarian kata kunci yang cocok secara case-insensitive',
      () async {
        // Act: Mencari kata 'tugas' huruf kecil, padahal data asli 'Tugas Mobile Programming'
        final (notes, failure) = await useCase('tugas');

        // Assert
        expect(failure, isNull);
        expect(notes, isNotNull);
        expect(notes!.isNotEmpty, isTrue);
        expect(
          notes.any((note) => note.title.contains('Tugas Mobile Programming')),
          isTrue,
        );
      },
    );

    test(
      'Skenario Gagal / Empty: Pencarian kata kunci yang tidak ada harus mengembalikan list kosong',
      () async {
        // Act: Mencari kata kunci yang tidak terdapat dalam catatan
        final (notes, failure) = await useCase('kata-kunci-tidak-ada-xyz');

        // Assert
        expect(failure, isNull);
        expect(notes, isNotNull);
        expect(notes!.isEmpty, isTrue);
      },
    );

    test(
      'Skenario Edge Case: Query kosong mengembalikan seluruh catatan',
      () async {
        // Act: Query string kosong
        final (notes, failure) = await useCase('');

        // Assert
        expect(failure, isNull);
        expect(notes, isNotNull);
        expect(notes!.length, equals(3));
      },
    );

    test(
      'Skenario Edge Case: Query berisi spasi di awal/akhir ditangani dengan baik (sanitized trim)',
      () async {
        // Act: Query dengan spasi berlebih
        final (notes, failure) = await useCase('   riverpod   ');

        // Assert
        expect(failure, isNull);
        expect(notes, isNotNull);
        expect(notes!.length, equals(1));
        expect(notes.first.title, contains('Riverpod'));
      },
    );
  });
}

