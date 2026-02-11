/// Form validators for Flutter text form fields.
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: validateEmail,
///   decoration: InputDecoration(
///     labelText: 'Email',
///   ),
/// )
/// ```
library;

/// Email validation regex pattern.
final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

/// Password requirements.
const int _minPasswordLength = 8;

/// Validate email format.
///
/// Returns null if valid, otherwise returns an error message.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!_emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validate password.
///
/// Returns null if valid, otherwise returns an error message.
/// Checks for minimum length (8 characters).
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < _minPasswordLength) {
    return 'Password must be at least $_minPasswordLength characters';
  }
  return null;
}

/// Validate confirm password matches original password.
///
/// Returns null if valid, otherwise returns an error message.
String? validateConfirmPassword(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

/// Validate required field (non-empty string).
///
/// Returns null if valid, otherwise returns an error message.
String? validateRequired(String? value, [String fieldName = 'This field']) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

/// Validate name field (letters, spaces, hyphens, apostrophes allowed).
String? validateName(String? value, [String fieldName = 'Name']) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  final trimmed = value.trim();
  if (trimmed.length < 2) {
    return '$fieldName must be at least 2 characters';
  }
  if (trimmed.length > 100) {
    return '$fieldName is too long (max 100 characters)';
  }
  return null;
}

/// Validate project name.
String? validateProjectName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Project name is required';
  }
  final trimmed = value.trim();
  if (trimmed.length > 255) {
    return 'Project name is too long (max 255 characters)';
  }
  return null;
}

/// Validate OTP code (6 digits).
String? validateOTP(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'OTP code is required';
  }
  final trimmed = value.trim();
  if (trimmed.length != 6) {
    return 'OTP code must be 6 digits';
  }
  if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
    return 'OTP code must contain only numbers';
  }
  return null;
}

/// Get strong password validation (optional stricter rules).
///
/// Checks for:
/// - Minimum length of 8 characters
/// - At least one lowercase letter
/// - At least one uppercase letter
/// - At least one number
/// - At least one special character
String? validateStrongPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < _minPasswordLength) {
    return 'Password must be at least $_minPasswordLength characters';
  }
  if (!RegExp('[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp('[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp('[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null;
}

/// Validate date range (end date must be after start date).
String? validateDateRange(DateTime? startDate, DateTime? endDate) {
  if (startDate != null && endDate != null) {
    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }
  }
  return null;
}

/// Multi-validator that runs multiple validators in sequence.
///
/// Returns the first error message found, or null if all pass.
String? validateMultiple(
  String? value,
  List<String? Function(String?)> validators,
) {
  for (final validator in validators) {
    final error = validator(value);
    if (error != null) {
      return error;
    }
  }
  return null;
}
