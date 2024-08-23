import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Configuración del parpadeo
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? imagePaths = prefs.getStringList('images');
    if (imagePaths != null) {
      setState(() {
        _images = imagePaths.map((path) => File(path)).toList();
      });
    }
  }

  Future<void> _saveImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imagePaths = _images.map((file) => file.path).toList();
    await prefs.setStringList('images', imagePaths);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      });
      await _saveImages();
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
      _saveImages();
    });
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay imágenes. Por favor, sube una imagen.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: _images.isNotEmpty
                ? CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 400.0,
                      enlargeCenterPage: true,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index, realIndex) {
                      return Stack(
                        children: [
                          InteractiveViewer(
                            clipBehavior: Clip.none,
                            boundaryMargin: EdgeInsets.all(20.0),
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: Image.file(_images[index]),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteImage(index),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Center(child: Text('No hay imágenes disponibles.')),
          ),
          SizedBox(height: 20),
          FadeTransition(
            opacity: _animationController?.drive(
              CurveTween(curve: Curves.easeInOut),
            ) ?? AlwaysStoppedAnimation(1.0),
            child: ElevatedButton(
              onPressed: _pickImages,
              child: Text('Agregar Imágenes'),
            ),
          ),
        ],
      ),
    );
  }
}
