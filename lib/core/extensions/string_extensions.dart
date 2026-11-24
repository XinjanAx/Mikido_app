extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    return split(' ').map((w) => w.capitalize()).join(' ');
  }

  /// Primera letra de cada palabra en mayúscula, sin tocar el resto (así
  /// "mcDonald" o siglas escritas a propósito se respetan). También quita
  /// espacios dobles: "  alexander   condor " → "Alexander Condor".
  String capitalizeWords() => trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  bool get isValidEmail {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(this);
  }

  bool get isValidPassword => length >= 6;
}
