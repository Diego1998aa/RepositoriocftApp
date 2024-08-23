class Comment {
  final int? id;
  final String content;

  Comment({this.id, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }
}
