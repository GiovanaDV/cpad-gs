import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/core/validators.dart';

void main() {
  group('descrição da ocorrência', () {
    test('exige preenchimento', () {
      expect(Validators.description(null), isNotNull);
      expect(Validators.description('   '), isNotNull);
    });

    test('rejeita texto curto', () {
      expect(Validators.description('curto'), isNotNull);
    });

    test('aceita descrição válida', () {
      expect(Validators.description('Vazamento na calçada perto da praça'), isNull);
    });

    test('não confunde números curtos com dados pessoais', () {
      expect(Validators.description('Vazamento na rua 12 há 3 dias'), isNull);
    });

    test('rejeita CPF, telefone e e-mail', () {
      expect(Validators.description('Meu CPF é 123.456.789-09 para contato'), isNotNull);
      expect(Validators.description('Ligar para (11) 98765-4321 por favor'), isNotNull);
      expect(Validators.description('Escreva para maria@email.com sobre o cano'), isNotNull);
    });

    test('rejeita texto acima de 200 caracteres', () {
      expect(Validators.description('a' * 201), isNotNull);
    });
  });

  group('campos numéricos', () {
    test('aceita vírgula e ponto decimais', () {
      expect(Validators.number('12,5', min: 1, max: 100), isNull);
      expect(Validators.number('12.5', min: 1, max: 100), isNull);
    });

    test('rejeita vazio, texto e fora da faixa', () {
      expect(Validators.number('', min: 1, max: 100), isNotNull);
      expect(Validators.number('abc', min: 1, max: 100), isNotNull);
      expect(Validators.number('0', min: 1, max: 100), isNotNull);
      expect(Validators.number('101', min: 1, max: 100), isNotNull);
    });

    test('exige inteiro quando pedido', () {
      expect(Validators.number('2,5', min: 1, max: 20, integer: true), isNotNull);
      expect(Validators.number('3', min: 1, max: 20, integer: true), isNull);
    });
  });

  test('escolha obrigatória em dropdown', () {
    expect(Validators.requiredChoice(null, 'Selecione'), 'Selecione');
    expect(Validators.requiredChoice('Vazamento', 'Selecione'), isNull);
  });
}