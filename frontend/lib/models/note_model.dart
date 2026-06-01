import 'dart:convert';

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
      id: json['id'] as int,
      title: json['title'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}