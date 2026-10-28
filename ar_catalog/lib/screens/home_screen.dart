// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';
import 'package:ar_catalog/widgets/model_card.dart';
import 'package:ar_catalog/screens/ar_screen.dart';
import 'package:ar_catalog/screens/scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final ModelRepository repository;
  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ArModel> _models = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isNavigating = false; // Защита от двойных нажатий

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final models = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is RepositoryException
            ? e.message
            : 'Ошибка загрузки данных';
        _isLoading = false;
      });
    }
  }

  // Метод открытия ArScreen
  Future<void> _openArScreen(ArModel model) async {
    // Защита от быстрых двойных нажатий
    if (_isNavigating) return;

    try {
      _isNavigating = true;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArScreen(model: model)),
      );
    } finally {
      // Сбрасываем флаг только если виджет ещё существует
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  // Метод открытия ScannerScreen
  Future<void> _openScannerScreen() async {
    if (_isNavigating) return;

    try {
      _isNavigating = true;
      final selectedModel = await Navigator.push<ArModel?>(
        context,
        MaterialPageRoute(
          builder: (context) => ScannerScreen(repository: widget.repository),
        ),
      );

      // Если вернулись с моделью и виджет ещё существует, открываем ArScreen
      if (selectedModel != null && mounted) {
        await _openArScreen(selectedModel);
      }
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  // Меню действий при долгом нажатии на карточку
  void _showCardActions(ArModel model) {
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Редактировать название'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showEditDialog(model);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Удалить модель',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showDeleteDialog(model);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Диалог редактирования названия
  void _showEditDialog(ArModel model) {
    final controller = TextEditingController(text: model.title);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Редактировать название'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Новое название',
                      errorText: errorMessage,
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () async {
                    final newTitle = controller.text.trim();
                    if (newTitle.isEmpty) {
                      setDialogState(
                        () => errorMessage = 'Название не может быть пустым',
                      );
                      return;
                    }

                    // Создаем новую модель с прежними полями, но новым названием
                    final updatedModel = ArModel(
                      id: model.id,
                      title: newTitle,
                      description: model.description,
                      modelPath: model.modelPath,
                      previewPath: model.previewPath,
                      type: model.type,
                      scale: model.scale,
                    );

                    try {
                      final success = await widget.repository.update(
                        updatedModel,
                      );
                      // используем dialogContext.mounted для безопасности
                      if (!dialogContext.mounted) return;

                      if (success) {
                        Navigator.pop(dialogContext);
                        _loadModels(); // Перезагружаем каталог после успеха
                      } else {
                        setDialogState(
                          () => errorMessage = 'Не удалось обновить модель',
                        );
                      }
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      // используем this.context для SnackBar после закрытия диалога
                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Диалог подтверждения удаления
  void _showDeleteDialog(ArModel model) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить модель?'),
          content: Text('Вы уверены, что хотите удалить "${model.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  final success = await widget.repository.delete(model.id);
                  // ИСПРАВЛЕНИЕ: используем dialogContext.mounted
                  if (!dialogContext.mounted) return;

                  if (success) {
                    Navigator.pop(dialogContext);
                    _loadModels(); // Перезагружаем каталог после успеха
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  // ИСПРАВЛЕНИЕ: используем this.context для SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $e')),
                  );
                }
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Catalog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Кнопка повторной загрузки
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadModels,
            tooltip: 'Обновить каталог',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded задает согласованные ограничения высоты для AnimatedSwitcher
            Expanded(
              // AnimatedSwitcher для плавной смены состояний
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isLoading
                    ? const Center(
                        key: ValueKey('loading'), // Уникальный ключ состояния
                        child: CircularProgressIndicator(),
                      )
                    : _errorMessage != null
                    ? Center(
                        key: const ValueKey(
                          'error',
                        ), // Уникальный ключ состояния
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadModels,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : _models.isEmpty
                    ? const Center(
                        key: ValueKey('empty'), // Уникальный ключ состояния
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Каталог пуст',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        key: const ValueKey(
                          'success',
                        ), // Уникальный ключ состояния
                        builder: (context, constraints) {
                          // Минимальная удобная ширина карточки 200px
                          final cardMinWidth = 200.0;
                          final maxColumns =
                              (constraints.maxWidth / cardMinWidth).floor();
                          final useGridView = maxColumns >= 2;

                          if (useGridView) {
                            // GridView для широкого экрана
                            return GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        300, // Макс. ширина карточки
                                    childAspectRatio:
                                        0.75, // Соотношение сторон (4:3 изображение + текст)
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _models.length,
                              itemBuilder: (context, index) {
                                final model = _models[index];
                                // ИСПРАВЛЕНИЕ: Добавлен GestureDetector для долгого нажатия
                                return GestureDetector(
                                  onLongPress: () => _showCardActions(model),
                                  child: ModelCard(
                                    key: ValueKey(
                                      model.id,
                                    ), // Стабильный ключ по id сохранен
                                    model: model,
                                    onTap: () => _openArScreen(model),
                                  ),
                                );
                              },
                            );
                          } else {
                            // ListView для узкого экрана
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _models.length,
                              itemBuilder: (context, index) {
                                final model = _models[index];
                                // Добавлен GestureDetector для долгого нажатия
                                return GestureDetector(
                                  onLongPress: () => _showCardActions(model),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: ModelCard(
                                      key: ValueKey(
                                        model.id,
                                      ), // Стабильный ключ по id сохранен
                                      model: model,
                                      onTap: () => _openArScreen(model),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _openScannerScreen,
        label: const Text('Сканировать QR'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
