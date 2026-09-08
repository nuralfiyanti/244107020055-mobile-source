import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.school, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nur Alfiyanti',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('NIM: 244107020055'),
              const Text('Kelas: TI-3E'),
              const SizedBox(height: 8),
              const Text('Politeknik Negeri Malang'),
              const Text('Pemrograman Mobile — Minggu 1'),
            ],
          ),
        ),
      ),
    );
  }
}