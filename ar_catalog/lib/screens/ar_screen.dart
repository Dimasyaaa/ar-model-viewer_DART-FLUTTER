import 'package:flutter/material.dart';
import 'package:ar_catalog/models/ar_model.dart';

class ArScreen extends StatelessWidget {
  // Обязательный параметр. Мы НЕ ищем модель по ID здесь.
  final ArModel model;

  const ArScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(model.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          // возможность прокрутки для больших описаний
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  model.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Тип: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(model.typeName),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Масштаб: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${model.scale}x'),
                  ],
                ),
                const SizedBox(height: 32),
                // Явная заглушка, как требует п. 19
                Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.view_in_ar, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '3D-просмотр будет подключён позже',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
