import 'package:flutter/material.dart';
import 'package:ar_catalog/repositories/model_repository.dart';

class ScannerScreen extends StatelessWidget {
  // Параметр на будущее
  final ModelRepository repository;

  const ScannerScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование QR')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'Здесь будет интерфейс камеры для сканирования QR-кодов.\n\n(Функционал будет добавлен позже)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
