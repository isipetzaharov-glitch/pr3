class Validators {
  static String? required(String? v, {String field = 'Поле'}) {
    if (v == null || v.trim().isEmpty) return '$field обязательно';
    return null;
  }

  static String? minLength(String? v, int n, {String field = 'Поле'}) {
    if (v == null || v.trim().length < n) {
      return '$field: минимум $n символов';
    }
    return null;
  }

  static String? maxLength(String? v, int n, {String field = 'Поле'}) {
    if (v != null && v.length > n) {
      return '$field: максимум $n символов';
    }
    return null;
  }

  static String? intRange(
    String? v,
    int min,
    int max, {
    String field = 'Значение',
  }) {
    if (v == null || v.isEmpty) return '$field обязательно';
    final n = int.tryParse(v);
    if (n == null) return '$field должно быть числом';
    if (n < min || n > max) return '$field: от $min до $max';
    return null;
  }

  static String? positiveDouble(String? v, {String field = 'Значение'}) {
    if (v == null || v.isEmpty) return '$field обязательно';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return '$field должно быть числом';
    if (n <= 0) return '$field должно быть больше нуля';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email обязателен';
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]{2,}$');
    if (!re.hasMatch(v.trim())) return 'Некорректный email';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Телефон обязателен';
    final re = RegExp(r'^[\d\+\-\(\)\s]{7,20}$');
    if (!re.hasMatch(v.trim())) return 'Некорректный телефон';
    return null;
  }

  static String? vin(String? v) {
    if (v == null || v.trim().isEmpty) return 'VIN обязателен';
    if (v.trim().length != 17) return 'VIN должен содержать ровно 17 символов';
    return null;
  }
}
