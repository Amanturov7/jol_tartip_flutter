import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageSelectorBox extends StatefulWidget {
  final Function(File?) onSelectImage;
  final File? imageFile;

  const ImageSelectorBox({
    Key? key,
    required this.onSelectImage,
    this.imageFile,
  }) : super(key: key);

  @override
  _ImageSelectorBoxState createState() => _ImageSelectorBoxState();
}

class _ImageSelectorBoxState extends State<ImageSelectorBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showImagePicker(context);
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: widget.imageFile != null
                  ? Center(
                      child: Image.file(
                        widget.imageFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.camera_alt),
            ),
          ),
        ),
        if (widget.imageFile != null) ...[
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onSelectImage(null);
                },
                child: Text('Отменить'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imageFile: widget.imageFile!),
                    ),
                  );
                },
                child: Text('Предпросмотр'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      widget.onSelectImage(File(pickedFile.path));
    }
  }

  void _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      widget.onSelectImage(File(pickedFile.path));
    }
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;

  const ImagePreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Предпросмотр'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
