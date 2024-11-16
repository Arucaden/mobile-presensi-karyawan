import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector;

  FaceDetectionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: true, // Untuk mendapatkan kontur wajah
            enableClassification: true, // Deteksi fitur wajah (smiling, eyes open)
          ),
        );

  /// Mendeteksi wajah dari gambar input
  Future<List<Face>> detectFaces(InputImage image) async {
    try {
      final faces = await _faceDetector.processImage(image);
      return faces;
    } catch (e) {
      print("Error detecting faces: $e");
      throw Exception("Failed to detect faces.");
    }
  }

  /// Menutup detektor
  void close() {
    _faceDetector.close();
  }
}
