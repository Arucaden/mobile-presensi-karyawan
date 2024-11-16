import 'package:http/http.dart' as http;
import 'dart:convert';

class APIService {
  final String baseUrl = 'http://192.168.1.40:8000/api';

  Future<void> sendFaceVector(List<double> faceVector, String idKaryawan) async {
    final url = Uri.parse('$baseUrl/check-face-match');

    // Prepare the JSON payload
    final payload = {
      'id_karyawan': idKaryawan,
      'face_vector': faceVector,
    };

    // Send POST request with JSON body
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      print('Attendance recorded successfully!');
    } else {
      print('Failed to record attendance: ${response.body}');
    }
  }
}
