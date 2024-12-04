import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:presensi_karyawan/services/all_in_one_service.dart';

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  CameraController? _cameraController;
  bool isDetecting = false;
  late FaceDetector _faceDetector;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  // Instance of AllInOneService
  final _faceDetectionService = AllInOneService();

  @override
  void initState() {
    super.initState();
    _initializeCameraList();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: false,
        enableLandmarks: false,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCameraList() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _initializeCamera(selectedCameraIndex);
      } else {
        print("No cameras available.");
      }
    } catch (e) {
      print("Error initializing camera list: $e");
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _switchCamera() {
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    _initializeCamera(selectedCameraIndex);
  }

  Future<void> _captureAndDetectFaces() async {
    if (isDetecting) return;
    isDetecting = true;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Capture image
      final XFile imageFile = await _cameraController!.takePicture();

      // Convert XFile to File
      final File file = File(imageFile.path);

      // Send face data to server and get the response message
      final String responseMessage = await _faceDetectionService.sendFaceData(file);

      // Dismiss loading indicator
      Navigator.of(context).pop();

      // Show response message in a dialog
      _showResponseDialog(responseMessage);
    } catch (e) {
      // Dismiss loading indicator
      Navigator.of(context).pop();

      // Show error message in dialog
      _showResponseDialog('Error: ${e.toString()}');
    } finally {
      isDetecting = false;
    }
  }

  void _showResponseDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Presensi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, navigate to another page or reset the camera
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition Attendance'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: _switchCamera, // Switch camera when tapped
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_cameraController == null || !_cameraController!.value.isInitialized)
            Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _captureAndDetectFaces, // Capture and process image
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.blue, // Background color
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
