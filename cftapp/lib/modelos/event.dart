class Event {
  final int? id;
  final String title;
  final int type;
  final DateTime date;

  Event({
    this.id,
    required this.title,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
