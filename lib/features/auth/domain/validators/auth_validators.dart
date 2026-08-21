class AuthValidators {
  AuthValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) return 'Enter your name';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().length < 8) return 'Enter a valid phone';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().length != 6) return 'Enter 6-digit OTP';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
