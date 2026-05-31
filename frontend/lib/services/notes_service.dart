"""Notes service for API calls."""
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../models/note_model.dart';
import 'auth_service.dart';


class NotesService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  NotesService() {
    _dio.options.baseUrl = 'http://localhost:8000/api';
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  Future<NoteModel> uploadNote(
    String filePath,
    String title, {
    Function(double)? onProgress,
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath);
      final formData = FormData.fromMap({
        'file': file,
        'title': title,
      });

      final response = await _dio.post(
        '/notes/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return NoteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await _dio.get('/notes/');
      final notes = (response.data as List)
          .map((note) => NoteModel.fromJson(note))
          .toList();
      return notes;
    } catch (e) {
      rethrow;
    }
  }

  Future<NoteModel> getNoteById(int id) async {
    try {
      final response = await _dio.get('/notes/$id');
      return NoteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
