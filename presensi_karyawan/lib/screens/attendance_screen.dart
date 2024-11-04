import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;
  List<Face>? _faces;
  late List<CameraDescription> _cameras;
  bool _isUsingFrontCamera = true;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final camera = _isUsingFrontCamera ? _cameras.first : _cameras.last;

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  void _toggleCamera() {
    setState(() {
      _isUsingFrontCamera = !_isUsingFrontCamera;
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);

    setState(() {
      _faces = faces;
    });
  }

  Future<void> _takePictureAndDetectFace() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      setState(() {
        _imageFile = image;
      });

      // Lakukan deteksi wajah pada gambar yang diambil
      await _detectFaces(File(image.path));

      // Tampilkan hasil di bottom sheet
      _showBottomSheet();
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // Tambahkan ini agar bottom sheet bisa menggunakan lebih banyak ruang layar
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(_imageFile!.path)),
                  ),
                Text(
                  _faces != null && _faces!.isNotEmpty
                      ? 'Jumlah Wajah Terdeteksi: ${_faces!.length}'
                      : 'Tidak ada wajah yang terdeteksi',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Wajah'),
        actions: [
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _takePictureAndDetectFace,
        child: Icon(Icons.camera_alt, size: 36),
      ),
    );
  }
}
