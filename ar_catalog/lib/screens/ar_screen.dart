import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/services/model_source_service.dart';

class ArScreen extends StatefulWidget {
  // Обязательный параметр. Мы НЕ ищем модель по ID здесь.
  final ArModel model;

  const ArScreen({super.key, required this.model});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  // ignore: unused_field
  final ModelSourceService _sourceService = ModelSourceService();

  bool _isLoading = true;
  String? _errorMessage;
  int _loadAttempt = 0; // Для генерации уникального Key при повторной загрузке
  bool _arAvailable = false; // Доступен ли AR режим

  @override
  void initState() {
    super.initState();
    _checkAndLoadModel();
  }

  // Проверка доступности asset перед загрузкой
  Future<void> _checkAndLoadModel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Пытаемся загрузить файл из assets
      await rootBundle.load(widget.model.modelPath);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Файл модели не найден в ресурсах приложения.';
        });
      }
    }
  }

  // Обработка сообщений из JavaScript
  void _handleJsMessage(JavaScriptMessage message) {
    if (!mounted) return;

    final msg = message.message;
    if (msg == 'loaded') {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _arAvailable = true;
      });
    } else if (msg.startsWith('error:')) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки GLB: ${msg.substring(6)}';
      });
    } else if (msg.startsWith('ar-status:')) {
      final status = msg.substring(10);
      debugPrint('AR Status: $status');
      if (status == 'failed' || status == 'not-presenting') {
        setState(() {
          _arAvailable = false;
        });
      } else if (status == 'session-started') {
        setState(() {
          _arAvailable = true;
        });
      }
    } else if (msg == 'ar-requested') {
      if (!_arAvailable) {
        _showArRequirementsDialog();
      }
    }
  }

  // JavaScript для регистрации слушателей событий model-viewer
  String get _relatedJs => '''
    document.addEventListener('DOMContentLoaded', () => {
      const viewer = document.getElementById('ar-catalog-viewer');
      if (viewer) {
        viewer.addEventListener('load', () => {
          ArCatalogEvents.postMessage('loaded');
        });
        viewer.addEventListener('error', (e) => {
          ArCatalogEvents.postMessage('error:' + (e.message || 'Unknown error'));
        });
        viewer.addEventListener('ar-status', (e) => {
          ArCatalogEvents.postMessage('ar-status:' + (e.detail ? e.detail.status : 'unknown'));
        });
        viewer.addEventListener('ar-requested', () => {
          ArCatalogEvents.postMessage('ar-requested');
        });
        
        // Проверка для позднего подключения: если модель уже загружена
        if (viewer.loaded) {
          ArCatalogEvents.postMessage('loaded');
        }
      }
    });
  ''';

  // Показывает диалог с требованиями к AR
  void _showArRequirementsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AR режим'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Для работы AR режима необходимо:'),
              SizedBox(height: 8),
              Text(
                '• Установленное приложение "Google Play Services for AR" (ARCore)',
              ),
              Text('• Поддержка камеры на устройстве'),
              Text(
                '• Поддерживаемое устройство (список: developers.google.com/ar/discover/supported-devices)',
              ),
              SizedBox(height: 16),
              Text(
                'На этом устройстве AR недоступен. 3D просмотр модели всё ещё работает.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  void _retryLoading() {
    setState(() {
      _loadAttempt++; // Меняем Key, чтобы пересоздать ModelViewer
    });
    _checkAndLoadModel();
  }

  @override
  Widget build(BuildContext context) {
    // Определяем источник модели. На мобильных платформах model_viewer_plus
    // использует локальный HTTP-прокси, который для http(s) URL делает 302
    // редирект — это вызывает краш рендерера WebView. Поэтому используем
    // локальный ассет (файл уже в bundles через pubspec.yaml assets:).
    var sourceUrl = widget.model.modelPath;

    // Выводим в консоль для проверки корректности пути
    debugPrint('========================================');
    debugPrint('modelPath из БД: ${widget.model.modelPath}');
    debugPrint('Итоговый sourceUrl: $sourceUrl');
    debugPrint('========================================');

    // Дополнительная проверка и вывод
    if (sourceUrl.isEmpty) {
      debugPrint('ВНИМАНИЕ: sourceUrl пустой! Используем fallback');
      sourceUrl = widget.model.modelPath; // Fallback к пути из модели
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _retryLoading,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить загрузку'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Превью модели
                      Hero(
                        tag: widget.model.heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              widget.model.previewPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      ),
                      const SizedBox(height: 24),

                      Text(
                        widget.model.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        widget.model.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Тип: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(widget.model.typeName),
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
                          Text('${widget.model.scale}x'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Интерактивный 3D-просмотр и AR
                      Container(
                        width: double.infinity,
                        height: 350, // Ограниченная высота для ModelViewer
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ModelViewer(
                            key: ValueKey(
                              '${widget.model.modelPath}_$_loadAttempt',
                            ), // Уникальный Key
                            src: sourceUrl, // Используем прямую HTTPS ссылку
                            alt: widget.model.title,
                            id: 'ar-catalog-viewer', // Постоянный DOM id
                            cameraControls: true,
                            autoRotate: true,
                            ar: true, // Разрешаем AR
                            arModes: const ['scene-viewer'],
                            scale:
                                '${widget.model.scale} ${widget.model.scale} ${widget.model.scale}',
                            relatedJs: _relatedJs,
                            javascriptChannels: <JavascriptChannel>{
                              JavascriptChannel(
                                'ArCatalogEvents',
                                onMessageReceived: _handleJsMessage,
                              ),
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _arAvailable
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _arAvailable ? Colors.green : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _arAvailable
                                  ? Icons.camera_alt
                                  : Icons.info_outline,
                              color: _arAvailable ? Colors.green : Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _arAvailable
                                    ? 'AR режим доступен. Нажмите иконку куба в углу для запуска AR.'
                                    : 'Используйте 1 палец для вращения, 2 для масштаба. AR требует устройство с ARCore и камерой.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _arAvailable
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
