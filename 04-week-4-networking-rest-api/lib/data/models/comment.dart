/// Model satu komentar dari JSONPlaceholder (GET /comments?postId={id}).
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

  /// Parsing JSON yang aman terhadap null dan field yang hilang.
  /// - Angka dibaca lewat `num?` lalu `toInt()`, default 0.
  /// - String dibaca lewat `String?`, default string kosong.
  /// Dengan pola ini tidak ada cast langsung yang bisa melempar
  /// `type 'Null' is not a subtype of type ...`.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}