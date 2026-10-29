import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/services/qr_catalog_service.dart';
import 'package:ar_catalog/widgets/scanner_frame.dart';

class ScannerScreen extends StatefulWidget {
  // Параметр на будущее
  final ModelRepository repository;

  const ScannerScreen({super.key, required this.repository});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

// Добавляем WidgetsBindingObserver для управления жизненным циклом
class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  // Контроллер создаётся один раз и освобождается при уничтожении виджета
  late final TextEditingController _inputController;

  // Новые контроллеры и сервис
  late final MobileScannerController _cameraController;
  late final QrCatalogService _qrService;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;

  String? _errorMessage;
  // Локальное состояние для управления визуальной рамкой
  ScannerStatus _scannerStatus = ScannerStatus.waiting;

  // Флаг блокировки для предотвращения дублирования запросов
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();

    // Регистрируем наблюдатель жизненного цикла
    WidgetsBinding.instance.addObserver(this);

    _qrService = QrCatalogService(widget.repository);

    // Отключаем автозапуск, ограничиваем распознавание только QR-кодами
    _cameraController = MobileScannerController(
      autoStart: false,
      formats: const [BarcodeFormat.qrCode],
    );

    // Подписываемся на поток сканирования
    _barcodeSubscription = _cameraController.barcodes.listen(_handleBarcode);

    // Запускаем камеру после инициализации
    _startCamera();
  }

  @override
  void dispose() {
    // Удаляем наблюдатель жизненного цикла
    WidgetsBinding.instance.removeObserver(this);

    // Отменяем подписку на поток перед освобождением
    _barcodeSubscription?.cancel();
    _barcodeSubscription = null;

    // Освобождаем контроллер камеры
    _cameraController.dispose();

    _inputController.dispose(); // Освобождаем контроллер
    super.dispose();
  }

  // Управление жизненным циклом приложения
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      // Возобновляем только если не идет обработка и виджет активен
      if (!_isProcessing && mounted) {
        _startCamera();
      }
    }
  }

  // Безопасный запуск камеры
  Future<void> _startCamera() async {
    if (!mounted || _isProcessing) return;
    try {
      await _cameraController.start();
      if (mounted) {
        setState(() => _scannerStatus = ScannerStatus.waiting);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scannerStatus = ScannerStatus.error;
          _errorMessage =
              'Ошибка инициализации камеры. Проверьте разрешения в настройках.';
        });
      }
    }
  }

  // Обработка кадра с камеры
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    // Игнорируем, если уже обрабатываем запрос или штрихкодов нет
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    // Блокируем обработку и останавливаем камеру ДО любого await
    setState(() {
      _isProcessing = true;
      _scannerStatus = ScannerStatus.processing;
      _errorMessage = null;
    });
    await _cameraController.stop();

    // Вызываем сервис для проверки строки
    final result = await _qrService.processQrString(barcode.rawValue);

    // Проверка mounted перед любыми действиями с UI
    if (!mounted) return;

    if (result.status == QrScanStatus.found) {
      // Возвращаем модель через pop, НЕ делая push отсюда
      // ignore: use_build_context_synchronously
      Navigator.pop(context, result.model);
    } else {
      setState(() {
        _scannerStatus = ScannerStatus.error;
        _errorMessage = result.status == QrScanStatus.invalid
            ? 'Некорректный идентификатор. Введите только цифры.'
            : 'Модель с таким идентификатором не найдена в каталоге.';
        // Снимаем блокировку, чтобы пользователь мог нажать "Сканировать снова"
        _isProcessing = false;
      });
    }
  }

  // Сброс ошибки и возобновление сканирования
  void _resetAndResume() {
    if (!mounted || _isProcessing) return;
    setState(() {
      _scannerStatus = ScannerStatus.waiting;
      _errorMessage = null;
    });
    _startCamera();
  }

  // Метод открытия диалога ручного ввода
  void _showManualInputDialog() async {
    // Останавливаем камеру на время диалога, чтобы сканер не сработал фоном
    await _cameraController.stop();

    _errorMessage = null;
    _inputController.clear();

    // Сбрасываем статус в ожидание при каждом открытии диалога
    setState(() {
      _scannerStatus = ScannerStatus.waiting;
    });

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible:
          false, // Запрещаем закрытие по клику вне диалога для контроля статуса
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Например: 2',
                      errorText: _errorMessage,
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
                    // Используем единый сервис для обработки
                    final result = await _qrService.processQrString(
                      _inputController.text,
                    );

                    if (!dialogContext.mounted) return;

                    if (result.status == QrScanStatus.found) {
                      Navigator.pop(dialogContext); // Закрываем диалог
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(
                          context,
                          result.model,
                        ); // Возвращаем модель в HomeScreen
                      }
                    } else {
                      setDialogState(() {
                        _errorMessage = result.status == QrScanStatus.invalid
                            ? 'Введите только цифры от 1 до 2147483647.'
                            : 'Модель не найдена в каталоге.';
                      });
                    }
                  },
                  child: const Text('Проверить'),
                ),
              ],
            );
          },
        );
      },
    );

    // После закрытия диалога возобновляем камеру, если экран все еще активен и не идет обработка
    if (mounted && !_isProcessing) {
      _startCamera();
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
        child: Stack(
          children: [
            // Слой 1: Камера на заднем плане
            MobileScanner(
              controller: _cameraController,
              // Обработка ошибок инициализации камеры
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ошибка камеры',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(error.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),

            // Слой 2: Декоративный слой поверх камеры
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: SingleChildScrollView(
                  // Добавлен, чтобы длинное сообщение об ошибке не вызывало overflow
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Область статуса сканера
                        ScannerFrame(status: _scannerStatus),
                        const SizedBox(height: 24),

                        if (_errorMessage != null) ...[
                          // Устойчивое состояние ошибки с кнопкой повтора
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _resetAndResume,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Сканировать снова'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Наведите камеру на QR с числом',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Диагностический ручной ввод
                        FilledButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : _showManualInputDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Проверить идентификатор вручную'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
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
            ),
          ],
        ),
      ),
    );
  }
}
