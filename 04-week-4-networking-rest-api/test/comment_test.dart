import 'package:flutter_test/flutter_test.dart';
import 'package:week4_networking/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman saat field hilang', () {
    // name, email, dan body sengaja tidak ada.
    final json = <String, dynamic>{'postId': 1, 'id': 5};

    final comment = Comment.fromJson(json);

    expect(comment.postId, 1);
    expect(comment.id, 5);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

    test('Comment.fromJson aman saat semua field null', () {
    final json = <String, dynamic>{
      'postId': null,
      'id': null,
      'name': null,
      'email': null,
      'body': null,
    };

    final comment = Comment.fromJson(json);

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}