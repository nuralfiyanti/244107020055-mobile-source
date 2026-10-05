/// Model satu komentar dari endpoint GET /comments?postId={id}.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// fromJson aman null: setiap field di-cast ke tipe nullable lebih dulu
  /// (`as num?`, `as String?`), lalu diberi nilai default dengan `??`.
  /// Jadi field yang hilang atau null tidak memicu crash
  /// "type 'Null' is not a subtype of type ...".
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // `num?` dipakai karena JSON bisa mengirim int atau double.
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}