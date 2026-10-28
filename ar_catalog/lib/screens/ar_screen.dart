import 'package:flutter/material.dart';
import 'package:ar_catalog/models/ar_model.dart';

class ArScreen extends StatelessWidget {
  // Обязательный параметр. Мы НЕ ищем модель по ID здесь.
  final ArModel model;

  const ArScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(model.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        // SingleChildScrollView позволяет прокручивать контент, если описание длинное
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Превью модели
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      model.previewPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Изображение недоступно',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Название модели
                Text(
                  model.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Полное описание модели
                Text(
                  model.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),

                // Дополнительные характеристики
                Row(
                  children: [
                    const Icon(Icons.category, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Тип: ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(model.typeName),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.aspect_ratio,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Масштаб: ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('${model.scale}x'),
                  ],
                ),

                const SizedBox(height: 32),

                // Явная заглушка для будущей AR-функциональности
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.view_in_ar, size: 64, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        '3D-просмотр будет подключён в ЛР8',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ), // Отступ снизу для комфортной прокрутки
              ],
            ),
          ),
        ),
      ),
    );
  }
}
