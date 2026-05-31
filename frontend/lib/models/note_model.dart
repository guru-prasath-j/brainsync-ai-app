"""Note model for Flutter."""
import 'package:intl/intl.dart';


class NoteModel {
  final int id;
  final String title;
  final String fileName;
  final int fileSize;
  final String status;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileSize,
    required this.status,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      fileName: json['file_name'] ?? '',
      fileSize: json['file_size'] ?? 0,
      status: json['status'] ?? 'uploaded',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'file_name': fileName,
    'file_size': fileSize,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
