class SummaryModel {
  final int noteId;
  final String tldr;
  final List<String> keyPoints;
  final List<String> concepts;
  final DateTime generatedAt;

  SummaryModel({
    required this.noteId,
    required this.tldr,
    required this.keyPoints,
    required this.concepts,
    required this.generatedAt,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      noteId: json['note_id'] as int,
      tldr: json['tldr'] as String? ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      concepts: List<String>.from(json['concepts'] ?? []),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'note_id': noteId,
        'tldr': tldr,
        'key_points': keyPoints,
        'concepts': concepts,
        'generated_at': generatedAt.toIso8601String(),
      };
}
