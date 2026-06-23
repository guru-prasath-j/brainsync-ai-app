import 'package:dio/dio.dart';
import 'package:brainsync_ai/core/api_client.dart';
import 'package:brainsync_ai/models/note_model.dart';

class NotesService {
  final Dio _dio = ApiClient.instance;

  Future<NoteModel> uploadNote({
    required List<int> bytes,
    required String filename,
    required String title,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = MultipartFile.fromBytes(bytes, filename: filename);
    final formData = FormData.fromMap({
      'title': title,
      'file': file,
    });

    final response = await _dio.post(
      '/api/notes/upload',
      data: formData,
      onSendProgress: onProgress,
    );

    return NoteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<NoteModel>> getNotes() async {
    final response = await _dio.get('/api/notes/');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> getNoteById(int id) async {
    final response = await _dio.get('/api/notes/' + id.toString());
    return NoteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNote(int id) async {
    await _dio.delete('/api/notes/' + id.toString());
  }
}