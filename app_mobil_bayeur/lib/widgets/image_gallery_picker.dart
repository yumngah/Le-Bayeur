import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageGalleryPicker extends StatefulWidget {
  final Function(List<File>) onImagesSelected;
  final int minImages;
  final int maxImages;

  const ImageGalleryPicker({
    super.key,
    required this.onImagesSelected,
    this.minImages = 3,
    this.maxImages = 10,
  });

  @override
  State<ImageGalleryPicker> createState() => _ImageGalleryPickerState();
}

class _ImageGalleryPickerState extends State<ImageGalleryPicker> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isCompressing = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _isCompressing = true);
      
      List<File> compressedFiles = [];
      for (var image in images) {
        final compressedFile = await _compressImage(File(image.path));
        if (compressedFile != null) {
          compressedFiles.add(compressedFile);
        }
      }

      setState(() {
        _selectedImages.addAll(compressedFiles);
        if (_selectedImages.length > widget.maxImages) {
          _selectedImages.removeRange(widget.maxImages, _selectedImages.length);
        }
        _isCompressing = false;
      });
      
      widget.onImagesSelected(_selectedImages);
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg");

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Galerie d'images (Min ${widget.minImages})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${_selectedImages.length}/${widget.maxImages}",
              style: TextStyle(color: _selectedImages.length >= widget.minImages ? Colors.green : Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isCompressing)
          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return _buildAddButton();
            }
            return _buildImageItem(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _selectedImages.length < widget.maxImages ? _pickImages : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Icon(Icons.add_a_photo, color: Colors.blue[700], size: 30),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImages[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
