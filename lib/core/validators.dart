/// Validações dos formulários. Funções puras, fáceis de testar.
class Validators {
  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');

  // 8 ou mais dígitos seguidos (aceitando separadores): pega CPF, telefone e CEP.
  static final _longNumber = RegExp(r'(?:\d[\s.\-()/]*){8,}');

  static bool looksPersonal(String text) => _email.hasMatch(text) || _longNumber.hasMatch(text);

  static String? requiredChoice(String? value, String message) =>
      (value == null || value.isEmpty) ? message : null;

  static String? description(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Descreva a ocorrência';
    if (text.length < 10) return 'Descreva com pelo menos 10 caracteres';
    if (text.length > 200) return 'Use no máximo 200 caracteres';
    if (looksPersonal(text)) {
      return 'Remova dados pessoais (CPF, telefone, e-mail ou números longos)';
    }
    return null;
  }

  /// Aceita vírgula ou ponto como separador decimal.
  static double? parseNumber(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  static String? number(String? value, {required double min, required double max, bool integer = false}) {
    if (value == null || value.trim().isEmpty) return 'Informe um valor';
    final n = parseNumber(value);
    if (n == null) return 'Use apenas números';
    if (integer && n != n.roundToDouble()) return 'Use um número inteiro';
    if (n < min || n > max) return 'Informe um valor entre ${_fmt(min)} e ${_fmt(max)}';
    return null;
  }

  static String _fmt(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1).replaceAll('.', ',');
}