/// Configuration for AI API service
class AiConfig {
  static const String baseUrl = 'https://ollama.com'; // Ollama cloud API
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const int maxHistoryMessages = 20;
  static const Duration minRequestInterval = Duration(seconds: 1);
}

/// Stream callback function type for real-time updates
typedef StreamCallback = void Function(String chunk);

/// Model class for Bible Q&A responses
class BibleQAResponse {
  final String answer;
  final List<BibleReference> references;

  const BibleQAResponse({required this.answer, required this.references});
}

/// Model class for Bible reference extraction
class BibleReference {
  final String book;
  final int chapter;
  final int verse;
  final int? endVerse;

  const BibleReference({
    required this.book,
    required this.chapter,
    required this.verse,
    this.endVerse,
  });

  @override
  String toString() {
    return '$book $chapter:$verse${endVerse != null ? '-$endVerse' : ''}';
  }
}

/// Model class for AI API error responses
class AiError implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const AiError({required this.message, this.statusCode, this.errorCode});

  @override
  String toString() =>
      'AiError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
