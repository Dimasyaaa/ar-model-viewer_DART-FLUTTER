import 'package:flutter/material.dart';
import 'package:ar_catalog/models/ar_model.dart';

class ModelCard extends StatefulWidget {
  final ArModel model;
  final VoidCallback onTap;

  const ModelCard({super.key, required this.model, required this.onTap});

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Управляем состоянием нажатия для мгновенной визуальной реакции
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(); // Вызываем основной callback
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        // Длительность 150-250 мс и явная кривая
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // Анимируем только небольшие изменения (цвет фона, рамку и тень)
        decoration: BoxDecoration(
          color: _isPressed
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: _isPressed ? 2.0 : 0.0,
          ),
          // Анимируем тень для эффекта "поднятия" карточки
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Область изображения
              Hero(
                tag: widget.model.heroTag,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    widget.model.previewPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Текстовая часть
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.model.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.model.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: _isPressed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: IgnorePointer(
                        ignoring: !_isPressed,
                        child: Text(
                          'ID: ${widget.model.id}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
