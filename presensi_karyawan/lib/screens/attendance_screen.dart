import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import '../services/tflite_service.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  late TFLiteService _tfliteService;
  bool _modelLoaded = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _tfliteService = TFLiteService();
    _loadModel();
  }

  Future<void> _loadModel() async {
    print('Loading model...');
    try {
      await _tfliteService.loadModel();
      setState(() {
        _modelLoaded = true;
      });
      print('Model loaded successfully.');
    } catch (e) {
      print('Error loading model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading model: $e')),
      );
    }
  }

  Future<void> _initializeCamera() async {
    print('Initializing camera...');
    try {
      final cameras = await availableCameras();
      final camera =
          cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController.initialize();
      setState(() {
        _cameraInitialized = true;
      });
      print('Camera initialized successfully.');
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  // ... Rest of the code remains the same ...

  Future<void> _processCapturedImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final boundingBox = face.boundingBox;

        // Load image using image package
        final bytes = await imageFile.readAsBytes();
        img.Image? originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          // Adjust bounding box to ensure it's within image bounds
          int x = boundingBox.left.toInt().clamp(0, originalImage.width);
          int y = boundingBox.top.toInt().clamp(0, originalImage.height);
          int width = boundingBox.width.toInt().clamp(0, originalImage.width - x);
          int height = boundingBox.height.toInt().clamp(0, originalImage.height - y);

          final croppedFace = img.copyCrop(
            originalImage,
            x: x,
            y: y,
            width: width,
            height: height,
          );

          final resizedFace = img.copyResize(
            croppedFace,
            width: 160,
            height: 160,
          );

          // Normalize image to [-1, 1]
          List<double> input = resizedFace
              .getBytes()
              .map((pixel) => (pixel - 127.5) / 127.5)
              .toList();

          // Predict face vector with TFLite
          final faceVector = await _tfliteService.predict(input);

          // Send to Laravel
          await _sendToLaravel(faceVector);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No face detected!')),
        );
      }
    } catch (e) {
      print('Error processing captured image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  Future<void> _sendToLaravel(List<double> faceVector) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.18.139:8000/api/check-face-match'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_karyawan': 2,
          'face_vector': faceVector,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['match'] == true) {
          // Display success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance recorded successfully!')),
          );
        } else {
          // Display failure message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Face does not match!')),
          );
        }
      } else {
        // Handle error response
        print("Error sending face vector: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record attendance!')),
        );
      }
    } catch (e) {
      print("Error sending face vector: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraInitialized || !_modelLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text("Attendance")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: CameraPreview(_cameraController),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          if (!_isDetecting && _modelLoaded) {
            _isDetecting = true;
            try {
              XFile picture = await _cameraController.takePicture();
              await _processCapturedImage(picture);
            } catch (e) {
              print('Error capturing image: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error capturing image: $e')),
              );
            } finally {
              _isDetecting = false;
            }
          } else if (!_modelLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Model is not loaded yet, please wait.')),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _tfliteService.close();
    super.dispose();
  }
}