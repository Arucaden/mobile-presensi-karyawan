import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Untuk menempatkan elemen di atas dan bawah
          crossAxisAlignment: CrossAxisAlignment.stretch, // Untuk membuat elemen memenuhi lebar
          children: [
            Column(
              children: [
                // Title dan Text
                const Center(
                  child: Text(
                    'yourKao',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Masuk sebagai Admin',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple[300],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Input Username
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Input Password
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Lupa password',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            ),
            // Button di bagian bawah kanan
            Align(
              alignment: Alignment.bottomRight,  // Mengatur posisi tombol di kanan bawah
              child: ElevatedButton(
                onPressed: () {
                  // Logic for login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
