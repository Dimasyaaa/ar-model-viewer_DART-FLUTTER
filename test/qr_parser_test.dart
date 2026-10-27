import 'package:test/test.dart';
import 'package:ar_project/services/qr_parser.dart';

void main() {
  group('parseQrId корректные значения', () {
    test('простой номер', () {
      expect(parseQrId('1'), equals(1));
      expect(parseQrId('42'), equals(42));
    });

    test('с пробелами по краям', () {
      expect(parseQrId('  3  '), equals(3));
      expect(parseQrId('\t1\n'), equals(1));
    });

    test('с ведущими нулями', () {
      expect(parseQrId('007'), equals(7));
      expect(parseQrId('0001'), equals(1));
    });

    test('максимальное значение', () {
      expect(parseQrId('2147483647'), equals(2147483647));
    });
  });

  group('parseQrId некорректные значения', () {
    test('пустая строка', () {
      expect(parseQrId(''), isNull);
      expect(parseQrId('   '), isNull);
    });

    test('null', () {
      expect(parseQrId(null), isNull);
    });

    test('буквы', () {
      expect(parseQrId('abc'), isNull);
      expect(parseQrId('12a'), isNull);
    });

    test('отрицательные', () {
      expect(parseQrId('-1'), isNull);
      expect(parseQrId('-100'), isNull);
    });

    test('ноль', () {
      expect(parseQrId('0'), isNull);
    });

    test('дробные', () {
      expect(parseQrId('1.5'), isNull);
      expect(parseQrId('3.14'), isNull);
    });

    test('знак плюс', () {
      expect(parseQrId('+1'), isNull);
    });

    test('внутренние пробелы', () {
      expect(parseQrId('1 2'), isNull);
      expect(parseQrId('12 34'), isNull);
    });

    test('hex формат', () {
      expect(parseQrId('0x10'), isNull);
      expect(parseQrId('FF'), isNull);
    });

    test('слишком большое число', () {
      expect(parseQrId('2147483648'), isNull);
      expect(parseQrId('9999999999'), isNull);
    });
  });
}
