import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class ArticleEditScreen extends StatefulWidget {
  final Article article;

  const ArticleEditScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleEditScreenState createState() => _ArticleEditScreenState();
}

class _ArticleEditScreenState extends State<ArticleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ArticleService _articleService = ArticleService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _descriptionController = TextEditingController(text: widget.article.descript);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                      _imageChanged = true;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                      _imageChanged = true;
                    });
                  }
                },
              ),
              if (widget.article.imageUrl != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Hapus Gambar'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _imageChanged = true;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateArticle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedArticle = await _articleService.updateArticle(
        id: widget.article.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFile: _imageChanged ? _selectedImage : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artikel berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedArticle);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui artikel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.article.imageUrl != null && !_imageChanged) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.article.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gambar tidak dapat dimuat',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap untuk menambah gambar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Artikel'),
        backgroundColor: Color(0xFF2686C2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateArticle,
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memperbarui artikel...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _buildImageWidget(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    const Text(
                      'Judul Artikel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul artikel...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2686C2),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul artikel tidak boleh kosong';
                        }
                        if (value.trim().length < 5) {
                          return 'Judul artikel minimal 5 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description Field
                    const Text(
                      'Deskripsi Artikel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Tulis deskripsi artikel di sini...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2686C2),
                            width: 2,
                          ),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi artikel tidak boleh kosong';
                        }
                        if (value.trim().length < 20) {
                          return 'Deskripsi artikel minimal 20 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateArticle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2686C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'PERBARUI ARTIKEL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
