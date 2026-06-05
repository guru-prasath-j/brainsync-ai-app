import 'package:intl/intl.dart';

class SummaryModel {
  final int id;
  final int noteId;
  final String tldr;
  final List<String> keyPoints;
  final List<String> concepts;
  final String modelUsed;
  final DateTime generatedAt;

  const SummaryModel({
    required this.id,
    required this.noteId,
    required this.tldr,
    required this.keyPoints,
    required this.concepts,
    required this.modelUsed,
    required this.generatedAt,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] as int,
      noteId: json['note_id'] as int,
      tldr: json['tldr'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      concepts: List<String>.from(json['concepts'] ?? []),
      modelUsed: json['model_used'] ?? 'gpt-4o-mini',
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'note_id': noteId,
        'tldr': tldr,
        'key_points': keyPoints,
        'concepts': concepts,
        'model_used': modelUsed,
        'generated_at': generatedAt.toIso8601String(),
      };

  String get formattedDate =>
      DateFormat('MMM d, yyyy • h:mm a').format(generatedAt.toLocal());
}
