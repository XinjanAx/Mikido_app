extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    return split(' ').map((w) => w.capitalize()).join(' ');
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(this);
  }

  bool get isValidPassword => length >= 6;
}
