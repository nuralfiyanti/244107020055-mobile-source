import 'package:flutter_test/flutter_test.dart';
import 'package:week4_networking/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('happy path: semua field lengkap', () {
      final c = Comment.fromJson({
        'postId': 1,
        'id': 5,
        'name': 'Nama',
        'email': 'a@b.com',
        'body': 'Isi',
      });
      expect(c.id, 5);
      expect(c.email, 'a@b.com');
    });

    test('field hilang: pakai nilai default, tidak crash', () {
      final c = Comment.fromJson({'id': 7, 'name': 'Hanya nama'});
      expect(c.id, 7);
      expect(c.postId, 0);
      expect(c.email, '');
      expect(c.body, '');
    });

    // Edge case tambahan (checklist: minimal 1 buatan sendiri)
    test('field bernilai null dan JSON kosong tidak crash', () {
      final nulls = Comment.fromJson({'id': null, 'name': null});
      expect(nulls.id, 0);
      expect(nulls.name, '');
      expect(Comment.fromJson({}).body, '');
    });
  });
}