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
                                return ModelCard(
                                  key: ValueKey(
                                    model.id,
                                  ), // Стабильный ключ по id сохранен
                                  model: model,
                                  onTap: () => _openArScreen(model),
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
                                return Padding(
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
