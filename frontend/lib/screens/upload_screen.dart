import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:brainsync_ai/services/notes_service.dart';
import 'package:brainsync_ai/widgets/aurora_scaffold.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _notesService = NotesService();
  PlatformFile? _selectedFile;
  double _uploadProgress = 0;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and enter a title')),
      );
      return;
    }
    setState(() { _isUploading = true; _uploadProgress = 0; });
    try {
      await _notesService.uploadNote(
        bytes: _selectedFile!.bytes!,
        filename: _selectedFile!.name,
        title: _titleController.text.trim(),
        onProgress: (sent, total) {
          setState(() => _uploadProgress = sent / total);
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
        context.go('/notes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ' + e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Upload Study Material'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a title for this material',
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile != null
                  ? _selectedFile!.name
                  : 'Select PDF or Text File'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Size: ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () => setState(() {
                              _selectedFile = null;
                              _titleController.clear();
                            }),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text('Remove', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            if (_isUploading) ...[
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text('Uploading... ' + (_uploadProgress * 100).toStringAsFixed(0) + '%',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _upload,
              icon: _isUploading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}