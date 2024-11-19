import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class FaceRecognitionPage extends StatefulWidget {
  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  File? _image;

  // Fungsi untuk mengambil gambar menggunakan kamera
  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Fungsi untuk mengirim gambar ke Laravel
  Future<void> _sendImageToServer() async {
    if (_image == null) return;
    final uri = Uri.parse('http://192.168.18.139:8000/api/check-face-match');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      // Cek respons apakah absensi berhasil atau gagal
      final respStr = await response.stream.bytesToString();
      print("Response: $respStr");
    } else {
      print("Failed to send image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition Attendance")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text("No image selected.")
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _getImage,
              child: Text("Take Picture"),
            ),
            ElevatedButton(
              onPressed: _sendImageToServer,
              child: Text("Send for Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
