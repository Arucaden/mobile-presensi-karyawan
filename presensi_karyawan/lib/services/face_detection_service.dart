import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class FaceDetectionService {
  final FaceDetector _faceDetector;
  Interpreter? _interpreter;

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

  Future<List<double>> predict(Uint8List inputData) async {
  try {
    if (_interpreter == null) {
      throw Exception("Interpreter is not initialized. Call loadModel() first.");
    }

    // Get input and output tensor shapes
    var inputShape = _interpreter!.getInputTensor(0).shape;
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    var inputType = _interpreter!.getInputTensor(0).type;

    // Check if inputType is uint8
    if (inputType != TfLiteType.kTfLiteUInt8) {
      throw Exception("Expected input tensor type uint8 but got $inputType");
    }

    // Reshape the input data
    var input = inputData.buffer.asUint8List();

    // Prepare output buffer
    var outputBuffer = Float32List(outputShape.reduce((a, b) => a * b));
    var output = outputBuffer.reshape(outputShape);

    // Run inference
    _interpreter!.run(input, output);

    // Flatten and return the output
    return outputBuffer.toList();
  } catch (e) {
    print("Error during prediction: $e");
    throw Exception("Failed to perform prediction.");
  }
}


  /// Menutup detektor
  void close() {
    _faceDetector.close();
  }
}
