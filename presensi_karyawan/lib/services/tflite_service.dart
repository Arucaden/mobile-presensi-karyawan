import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;

  static final TFLiteService _instance = TFLiteService._internal();

  TFLiteService._internal();

  factory TFLiteService() {
    return _instance;
  }

  /// Load the TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('facenet_model.tflite');

      // Ambil bentuk tensor input dan output
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      print("Model loaded successfully!");
      print("Input Shape: $_inputShape");
      print("Output Shape: $_outputShape");
    } catch (e) {
      print("Error while loading model: $e");
      throw Exception("Failed to load TFLite model.");
    }
  }

  /// Perform inference using the model
  Future<List<double>> predict(List<double> inputVector) async {
    try {
      if (_interpreter == null) {
        throw Exception("Interpreter is not initialized. Call loadModel() first.");
      }

      // Validasi ukuran input
      final inputSize = _inputShape.reduce((a, b) => a * b);
      if (inputVector.length != inputSize) {
        throw Exception(
          "Input size mismatch: Expected $inputSize but got ${inputVector.length}",
        );
      }

      // Siapkan input dan output untuk model
      final input = Float32List.fromList(inputVector); // Ubah input menjadi Float32List
      final output = List.generate(_outputShape.reduce((a, b) => a * b), (_) => 0.0)
          .reshape([_outputShape[0], _outputShape[1]]); // Hasil output

      // Jalankan model
      _interpreter.run(input, output);

      // Flatten hasil output menjadi List<double>
      return output.expand((e) => e).cast<double>().toList();
    } catch (e) {
      print("Error during prediction: $e");
      throw Exception("Failed to perform prediction.");
    }
  }

  /// Close the interpreter when done
  void close() {
    _interpreter.close();
  }
}
