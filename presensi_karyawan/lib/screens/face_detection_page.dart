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
  bool isFlashOn = false;
  bool isFrontCamera = true;
  late FaceDetector _faceDetector;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  int statusCode = 0;

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
        _initializeCamera(isFrontCamera ? _getFrontCamera() : _getBackCamera());
      } else {
        print("No cameras available.");
      }
    } catch (e) {
      print("Error initializing camera list: $e");
    }
  }

   CameraDescription _getFrontCamera() {
    return cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
  }

  CameraDescription _getBackCamera() {
    return cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
        _cameraController = CameraController(
      cameraDescription,
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

  void _switchCamera() async {
    isFrontCamera = !isFrontCamera;
    await _initializeCamera(isFrontCamera ? _getFrontCamera() : _getBackCamera());
  }

  void _toggleFlash() {
    if (_cameraController != null) {
      setState(() {
        isFlashOn = !isFlashOn;
        _cameraController!.setFlashMode(
          isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      });
    }
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
      
      statusCode = 500;
      String message = responseMessage;

          if (message.contains("berhasil")) {
            statusCode = 200;
          } else if (message.contains("Error") || message.contains("Gagal") || message.contains("error") || message.contains("gagal")) {
            statusCode = 500;
          } else {
            statusCode = 400; // Misal unknown error
          }

      // Dismiss loading indicator
      Navigator.of(context).pop();

      // Show response message in a dialog
      _showResponseDialog(message, statusCode); // Assuming 200 as a placeholder status code
    } catch (e) {
      // Dismiss loading indicator
      Navigator.of(context).pop();

      // Show error message in dialog
      _showResponseDialog('Error: ${e.toString()}', statusCode); // Assuming 500 as a placeholder error status code
    } finally {
      isDetecting = false;
    }
  }

  void _showResponseDialog(String message, int statusCode) {
    Icon icon;
    
    // Tentukan ikon berdasarkan statusCode
    if (statusCode == 200) {
      icon = Icon(Icons.check_circle, color: Colors.green, size: 64);
    } else if (statusCode == 500) {
      icon = Icon(Icons.error, color: Colors.red, size: 64);
    } else {
      icon = Icon(Icons.info, color: Colors.yellow[800], size: 64);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Presensi',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_cameraController == null || !_cameraController!.value.isInitialized)
            const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _switchCamera, // Switch camera when tapped
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.deepPurple[50], // Background color
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.sync,
                      size: 30,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _captureAndDetectFaces, // Capture and process image
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.white, // Background color
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _toggleFlash, // Toggle flashlight
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.deepPurple[50],
                      elevation: 0, // Background color
                    ),
                    child: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      size: 30,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
