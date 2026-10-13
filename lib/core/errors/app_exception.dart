class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

class RateLimitException extends AppException {
  const RateLimitException()
    : super('Pixabay rate limit reached. Please wait a moment and retry.', statusCode: 429);
}

class ConfigException extends AppException {
  const ConfigException()
    : super(
        'Pixabay API key is missing. Add it with --dart-define=PIXABAY_API_KEY=... '
        'or copy lib/core/config/secrets.example.dart to secrets.dart.',
      );
}
