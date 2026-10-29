import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';
import 'package:ar_catalog/services/qr_catalog_service.dart';

// Фейковый репозиторий для полного контроля над тестами (п. 31)
class FakeModelRepository implements ModelRepository {
  final Map<int, ArModel> _models = {
    2: ArModel(
      id: 2,
      title: 'Space Helmet',
      description: 'Test',
      modelPath: 'assets/models/helmet.glb',
      previewPath: 'assets/previews/helmet.png',
      type: ArModelType.space,
      scale: 1.0,
    ),
  };

  bool throwDatabaseError = false;

  @override
  Future<ArModel?> getById(int id) async {
    if (throwDatabaseError) {
      throw RepositoryException('Simulated DB error');
    }
    return _models[id];
  }

  @override
  Future<List<ArModel>> getAll() async => _models.values.toList();
  @override
  Future<void> insert(ArModel model) async => throw UnimplementedError();
  @override
  Future<bool> update(ArModel model) async => throw UnimplementedError();
  @override
  Future<bool> delete(int id) async => throw UnimplementedError();
}

void main() {
  group('QrCatalogService', () {
    late FakeModelRepository fakeRepository;
    late QrCatalogService service;

    setUp(() {
      fakeRepository = FakeModelRepository();
      service = QrCatalogService(fakeRepository);
    });

    test('возвращает invalid для null и пустой строки (п. 17)', () async {
      expect(
        (await service.processQrString(null)).status,
        QrScanStatus.invalid,
      );
      expect((await service.processQrString('')).status, QrScanStatus.invalid);
      expect(
        (await service.processQrString('   ')).status,
        QrScanStatus.invalid,
      );
    });

    test(
      'возвращает invalid для некорректных форматов (п. 5, таблица сценариев)',
      () async {
        final invalidInputs = [
          'abc',
          '-1',
          '0',
          '1.5',
          '+1',
          '0x10',
          '2x',
          'https://example.com',
        ];
        for (final input in invalidInputs) {
          final result = await service.processQrString(input);
          expect(
            result.status,
            QrScanStatus.invalid,
            reason: 'Failed for input: $input',
          );
        }
      },
    );

    test(
      'возвращает found для корректного ID, который есть в базе (п. 31)',
      () async {
        final result = await service.processQrString('2');
        expect(result.status, QrScanStatus.found);
        expect(result.model?.id, 2);
        expect(result.model?.title, 'Space Helmet');
      },
    );

    test(
      'возвращает notFound для корректного ID, которого нет в базе (п. 31)',
      () async {
        final result = await service.processQrString('17');
        expect(result.status, QrScanStatus.notFound);
        expect(result.model, isNull);
      },
    );

    test('возвращает storageError при сбое репозитория (п. 31)', () async {
      fakeRepository.throwDatabaseError = true;
      final result = await service.processQrString('2');
      expect(result.status, QrScanStatus.storageError);
      expect(result.model, isNull);
    });

    test(
      'корректно обрабатывает пробелы вокруг числа (п. 5, таблица сценариев)',
      () async {
        final result = await service.processQrString('  2  ');
        expect(result.status, QrScanStatus.found);
        expect(result.model?.id, 2);
      },
    );
  });
}
