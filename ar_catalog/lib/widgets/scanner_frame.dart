import 'package:flutter/material.dart';

// Состояния будущего сканера
enum ScannerStatus { waiting, processing, error }

class ScannerFrame extends StatefulWidget {
  final ScannerStatus status;

  const ScannerFrame({super.key, required this.status});

  @override
  State<ScannerFrame> createState() => _ScannerFrameState();
}

class _ScannerFrameState extends State<ScannerFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Создание контроллера с vsync
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Tween и CurvedAnimation для плавности
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );

    _updateAnimation();
  }

  // Обработка изменения статуса извне
  @override
  void didUpdateWidget(ScannerFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    // Запускаем повторяющийся эффект только в состоянии ожидания
    if (widget.status == ScannerStatus.waiting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  // Освобождение контроллера
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Учет предпочтения пользователя об отключении анимаций
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      return _buildFrame(1.0);
    }

    // AnimatedBuilder ограничивает перестроение только рамкой, не перестраивая весь экран
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildFrame(_animation.value);
      },
    );
  }

  Widget _buildFrame(double opacity) {
    Color borderColor;

    // Для обработки и ошибки показываем устойчивые цвета, а не мигание
    if (widget.status == ScannerStatus.error) {
      borderColor = Colors.red.shade700;
    } else if (widget.status == ScannerStatus.processing) {
      borderColor = Colors.orange.shade700;
    } else {
      // используем withValues
      borderColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: opacity);
    }

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: widget.status == ScannerStatus.processing
          ? const Center(child: CircularProgressIndicator())
          : widget.status == ScannerStatus.error
          ? const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 48),
            )
          : null, // В режиме waiting рамка просто пульсирует
    );
  }
}
