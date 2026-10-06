/// Input validators shared across authentication and profile forms.
library;

class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phoneRegExp = RegExp(r'^\+?[\d\s-]{7,}$');

  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final String? requiredError = required(value);
    if (requiredError != null) return 'Please enter your email address';
    if (!_emailRegExp.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final String? requiredError = required(value);
    if (requiredError != null) return 'Please enter a password';
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 72) {
      return 'Password must not exceed 72 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_phoneRegExp.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
