import 'package:flutter/material.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/services/qr_parser.dart';

class ScannerScreen extends StatefulWidget {
  // Параметр на будущее
  final ModelRepository repository;

  const ScannerScreen({super.key, required this.repository});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // Контроллер создаётся один раз и освобождается при уничтожении виджета
  late final TextEditingController _inputController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose(); // Освобождаем контроллер
    super.dispose();
  }

  // Метод открытия диалога ручного ввода
  void _showManualInputDialog() {
    _errorMessage = null;
    _inputController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Проверка идентификатора без камеры'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Введите числовой идентификатор модели (1–2147483647):',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Например: 2',
                ),
                autofocus: true,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => _processInput(dialogContext),
              child: const Text('Проверить'),
            ),
          ],
        );
      },
    );
  }

  // Обработка введённого значения
  Future<void> _processInput(BuildContext dialogContext) async {
    final inputValue = _inputController.text;

    // Шаг 1: Парсинг QR
    final id = parseQrId(inputValue);
    if (id == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Некорректный идентификатор. Введите только цифры от 1 до 2147483647.';
      });
      return;
    }

    // Шаг 2: Поиск модели в репозитории
    try {
      final model = await widget.repository.getById(id);

      // 1. Проверка для State.context перед любыми действиями
      if (!mounted) return;

      if (model == null) {
        setState(() {
          _errorMessage = 'Модель с ID $id не найдена в каталоге.';
        });
      } else {
        // 2. ПРЯМАЯ проверка для dialogContext перед его использованием
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext); // Закрываем диалог

        // 3. Повторная проверка для State.context перед возвратом результата
        if (!mounted) return;
        Navigator.pop(context, model); // Возвращаем модель в HomeScreen
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ошибка при поиске: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканирование QR'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
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
                  'Камера будет подключена позже.\n\n'
                  'Для проверки навигации используйте ручной ввод идентификатора.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _showManualInputDialog,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Проверить идентификатор вручную'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
