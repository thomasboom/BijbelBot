import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'logger.dart';
import '../models/ai_prompt_settings.dart';

/// Stream callback function type for real-time updates
typedef StreamCallback = void Function(String chunk);

/// Configuration for AI API service
class AiConfig {
  static const String baseUrl = 'https://ollama.com'; // Ollama cloud API
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const int maxHistoryMessages = 20;
}

/// Model class for Bible Q&A responses
class BibleQAResponse {
  final String answer;
  final List<BibleReference> references;

  const BibleQAResponse({
    required this.answer,
    required this.references,
  });
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

  const AiError({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'AiError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// A service that provides an interface to the AI API for Bible Q&A.
/// This is a standalone version specifically for the BijbelBot app.
class AiService {
  static AiService? _instance;
  String _apiKey = '';
  late final http.Client _httpClient;
  bool _initialized = false;
  String _normenText = '';

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  /// Private constructor for singleton pattern
  AiService._internal() {
    _httpClient = http.Client();
  }

  /// Gets the singleton instance of the service
  static AiService get instance {
    _instance ??= AiService._internal();
    return _instance!;
  }

  /// Checks if the service is properly initialized and ready to use
  bool get isInitialized => _initialized;

  /// Gets the current initialization status of the service
  bool get isReady => _initialized && _apiKey.isNotEmpty;

  /// Gets the API key for external access
  String get apiKey => _apiKey;

  /// Initializes the AI service with a user-provided API key
  Future<void> initialize({required String apiKey}) async {
    try {
      AppLogger.info('Initializing Ollama AI API service for BijbelBot...');

      final trimmedKey = apiKey.trim();
      if (trimmedKey.isEmpty) {
        throw const AiError(
          message: 'API key is required. Add your Ollama API key in the app settings.',
        );
      }

      // Validate API key format for cloud API
      if (trimmedKey.length < 20) {
        AppLogger.warning('OLLAMA_API_KEY appears to be too short - please verify it is correct');
      }

      _apiKey = trimmedKey;
      _normenText = await _loadNormenText();
      _initialized = true;
      AppLogger.info('Ollama AI API service initialized successfully for BijbelBot');
    } catch (e) {
      AppLogger.error('Failed to initialize Ollama AI API service', e);
      _initialized = false;
      rethrow;
    }
  }

  /// Ensures the service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      if (_apiKey.isEmpty) {
        throw const AiError(
          message: 'API key ontbreekt. Voeg je API key toe in de instellingen.',
        );
      }
      await initialize(apiKey: _apiKey);
    }
  }

  /// Answers a Bible-related question using AI
  Future<BibleQAResponse> askBibleQuestion(
    String question, {
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) async {
    if (question.trim().isEmpty) {
      throw const AiError(message: 'Question cannot be empty');
    }

    // Ensure service is initialized
    await _ensureInitialized();

    if (!_initialized || _apiKey.isEmpty) {
      throw const AiError(
        message: 'Ollama AI API service is not properly configured. Add your API key in the app settings.',
      );
    }

    await _ensureRateLimit();

    AppLogger.info('Asking Bible question: $question');

    try {
      final response = await _makeApiRequest(
        question,
        history: history,
        promptSettings: promptSettings,
      );

      if (response.statusCode == 200) {
        final bibleResponse = await _parseApiResponse(response.body);
        AppLogger.info('Successfully received Bible answer');
        return bibleResponse;
      } else {
        throw await _handleErrorResponse(response);
      }
    } catch (e) {
      AppLogger.error('Failed to get Bible answer', e);

      // Provide helpful error messages for common cloud API issues
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        throw AiError(
          message: 'Ongeldige API key. Controleer je API key in de instellingen. Verkrijg een nieuwe key van https://ollama.com/settings/keys',
        );
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        throw AiError(
          message: 'Model "ministral-3:14b-cloud" niet gevonden. Controleer of dit model beschikbaar is op https://ollama.com',
        );
      } else if (e.toString().contains('Connection refused') || e.toString().contains('SocketException')) {
        throw AiError(
          message: 'Kan geen verbinding maken met Ollama cloud API. Controleer je internetverbinding.',
        );
      }

      rethrow;
    }
  }

  /// Answers a Bible-related question using AI with streaming support
  Stream<String> askBibleQuestionStream(
    String question, {
    StreamCallback? onChunk,
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) async* {
    if (question.trim().isEmpty) {
      throw const AiError(message: 'Question cannot be empty');
    }

    // Ensure service is initialized
    await _ensureInitialized();

    if (!_initialized || _apiKey.isEmpty) {
      throw const AiError(
        message: 'Ollama AI API service is not properly configured. Add your API key in the app settings.',
      );
    }

    await _ensureRateLimit();

    AppLogger.info('Asking Bible question with streaming: $question');

    try {
      final request = await _makeStreamingApiRequestStream(
        question,
        history: history,
        promptSettings: promptSettings,
      );

      await for (final chunk in request) {
        yield chunk;
        if (onChunk != null) {
          onChunk(chunk);
        }
      }
    } catch (e) {
      AppLogger.error('Failed to get streaming Bible answer', e);
      rethrow;
    }
  }

  /// Ensures requests respect rate limiting
  Future<void> _ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final delay = _minRequestInterval - timeSinceLastRequest;
        AppLogger.info('Rate limiting: waiting ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Makes the HTTP request to the Ollama API
  Future<http.Response> _makeApiRequest(
    String question, {
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) async {
    final url = Uri.parse('${AiConfig.baseUrl}/api/chat');

    final requestBody = json.encode({
      'model': 'ministral-3:14b-cloud', // Use the cloud model as specified in the API key
      'messages': _buildMessages(question, history, promptSettings),
    });

    AppLogger.info('Making request to Ollama API');

    for (int attempt = 1; attempt <= AiConfig.maxRetries; attempt++) {
      try {
        final headers = {
          'Content-Type': 'application/json',
        };

        // Only add Authorization header if we have an API key
        if (_apiKey.isNotEmpty) {
          headers['Authorization'] = 'Bearer $_apiKey';
        }

        final response = await _httpClient
            .post(
              url,
              headers: headers,
              body: requestBody,
            )
            .timeout(AiConfig.requestTimeout);

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429 && attempt < AiConfig.maxRetries) {
          // Rate limited, wait and retry
          final delay = AiConfig.retryDelay * attempt;
          AppLogger.warning('Rate limited, retrying in ${delay.inSeconds}s (attempt $attempt)');
          await Future.delayed(delay);
          continue;
        } else {
          return response;
        }
      } catch (e) {
        if (attempt == AiConfig.maxRetries) {
          throw AiError(
            message: 'Network request failed after $attempt attempts: $e',
          );
        }
        AppLogger.warning('Request attempt $attempt failed: $e');
        await Future.delayed(AiConfig.retryDelay * attempt);
      }
    }

    throw const AiError(message: 'All retry attempts exhausted');
  }

  /// Parses the Ollama API response to extract Bible answer and references
  Future<BibleQAResponse> _parseApiResponse(String responseBody) async {
    try {
      AppLogger.info('Parsing API response...');

      final trimmed = responseBody.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final Map<String, dynamic> response = json.decode(trimmed);
        final message = response['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return _parseBibleResponse(content);
        }
      }

      // Handle streaming response format - split by newlines and parse each JSON object
      final lines = responseBody.split('\n').where((line) => line.trim().isNotEmpty);

      String fullContent = '';
      bool isDone = false;

      for (final line in lines) {
        try {
          final Map<String, dynamic> response = json.decode(line);

          // Extract content from this chunk
          final message = response['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;

          if (content != null && content.isNotEmpty) {
            fullContent += content;
          }

          // Check if this is the final chunk
          if (response['done'] == true) {
            isDone = true;
            break;
          }
        } catch (e) {
          AppLogger.warning('Failed to parse line as JSON: $line, Error: $e');
          // Continue with next line
        }
      }

      if (fullContent.trim().isEmpty) {
        throw const AiError(message: 'Empty response text');
      }

      final bibleResponse = _parseBibleResponse(fullContent);
      AppLogger.info('Successfully parsed Bible response');
      return bibleResponse;
    } catch (e) {
      if (e is AiError) rethrow;

      AppLogger.error('Failed to parse API response: $e');
      AppLogger.error('Response body: $responseBody');

      // As a last resort, try to extract any readable text from the response
      try {
        final responseStr = responseBody.toString();
        if (responseStr.contains('"content"')) {
          // Extract all content fields using regex
          final contentMatches = RegExp(r'"content"\s*:\s*"([^"]*)"').allMatches(responseStr);
          String fallbackText = '';
          for (final match in contentMatches) {
            if (match.groupCount >= 1) {
              fallbackText += match.group(1)!;
            }
          }

          if (fallbackText.isNotEmpty) {
            AppLogger.info('Using fallback text extraction');
            final normalizedText = _normalizeModelText(fallbackText);
            return BibleQAResponse(
              answer: normalizedText,
              references: _extractBibleReferences(normalizedText),
            );
          }
        }
      } catch (fallbackError) {
        AppLogger.error('Fallback parsing also failed: $fallbackError');
      }

      return BibleQAResponse(
        answer: 'Er is een fout opgetreden bij het verwerken van het antwoord. Probeer het opnieuw.',
        references: [],
      );
    }
  }

  /// Handles error responses from the AI API
  Future<AiError> _handleErrorResponse(http.Response response) async {
    try {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final error = errorBody['error'] as Map<String, dynamic>?;

      return AiError(
        message: error?['message'] as String? ?? 'Unknown API error',
        statusCode: response.statusCode,
        errorCode: error?['code'] as String?,
      );
    } catch (e) {
      return AiError(
        message: 'HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Builds a system prompt for Bible Q&A
  String _buildBiblePrompt(AiPromptSettings settings) {
    final normenBlock = _normenText.trim().isEmpty
        ? 'Normen: (geen normen geladen)'
        : 'Normen (uit normen.md):\n$_normenText';

    final styleBlock = _buildStyleInstructions(settings);
    final customBlock = settings.customInstruction.trim().isEmpty
        ? ''
        : '\nExtra instructies van de gebruiker:\n${settings.customInstruction.trim()}\n';

    return '''
Je bent een deskundige Bijbelkenner en leraar met een gereformeerde, traditionele christelijke visie. Antwoord in het Nederlands.

Richtlijnen voor je antwoord:
1. Geef accurate, Bijbels gefundeerde antwoorden, geworteld in de historische orthodoxie en de gereformeerde traditie
2. Wees respectvol, pastoraal en onderwijzend van toon
3. Voeg relevante Bijbelverwijzingen toe waar passend
4. Houd uitleg duidelijk en toegankelijk
5. Als de vraag over specifieke Bijbelteksten gaat, citeer ze waar relevant
6. Antwoord in het Nederlands
7. Als je het niet zeker weet, geef dat eerlijk aan en speculeer niet
8. Bij niet-Bijbelse vragen: geef een behulpzaam algemeen antwoord; wanneer waarden relevant zijn, benadruk expliciet het christelijke morele kader (bijv. kuisheid en seks binnen het huwelijk)
9. Vermijd harde of veroordelende taal; spreek met genade en waarheid

Stijlvoorkeuren:
$styleBlock
$customBlock

Gebruik het onderstaande normen-overzicht als waarde-kader:
$normenBlock

Structureer je antwoord als:
1. Een helder, direct antwoord op de vraag
2. Relevante Bijbelverwijzingen in het format "Boek Hoofdstuk:Vers"
3. Eventuele extra uitleg of context

Voorbeeld:
[Je antwoord hier]

Referenties: Genesis 1:1, Johannes 3:16
''';
  }

  String _buildStyleInstructions(AiPromptSettings settings) {
    String toneLine;
    switch (settings.tone) {
      case PromptTone.warm:
        toneLine = 'Toon: warm, vriendelijk en pastoraal.';
        break;
      case PromptTone.professional:
        toneLine = 'Toon: professioneel, helder en respectvol.';
        break;
      case PromptTone.functional:
        toneLine = 'Toon: functioneel, kort en to-the-point.';
        break;
    }

    String emojiLine;
    switch (settings.emojiLevel) {
      case EmojiLevel.more:
        emojiLine = 'Emoji\'s: gebruik regelmatig emoji\'s waar passend.';
        break;
      case EmojiLevel.normal:
        emojiLine = 'Emoji\'s: gebruik spaarzaam een paar emoji\'s waar passend.';
        break;
      case EmojiLevel.less:
        emojiLine = 'Emoji\'s: gebruik bij voorkeur geen emoji\'s.';
        break;
    }

    String formatLine;
    switch (settings.responseFormat) {
      case ResponseFormat.formatted:
        formatLine = 'Opmaak: gebruik duidelijke structuur met kopjes en/of lijstjes waar passend.';
        break;
      case ResponseFormat.longText:
        formatLine =
            'Opmaak: schrijf vooral in doorlopende tekst zonder opsommingen; zet "Referenties:" op een aparte regel.';
        break;
    }

    return '$toneLine\n$emojiLine\n$formatLine';
  }

  Future<String> _loadNormenText() async {
    try {
      return await rootBundle.loadString('normen.md');
    } catch (e) {
      AppLogger.warning('Could not load normen.md: $e');
      return '';
    }
  }

  List<Map<String, String>> _buildMessages(
    String question,
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  ) {
    final resolvedSettings = promptSettings ?? AiPromptSettings.defaults();
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': _buildBiblePrompt(resolvedSettings),
      },
    ];

    if (history != null && history.isNotEmpty) {
      final trimmedHistory = history
          .where((entry) => entry['content'] != null && entry['content']!.trim().isNotEmpty)
          .where((entry) => entry['role'] == 'user' || entry['role'] == 'assistant')
          .toList();

      final startIndex = trimmedHistory.length > AiConfig.maxHistoryMessages
          ? trimmedHistory.length - AiConfig.maxHistoryMessages
          : 0;

      messages.addAll(trimmedHistory.sublist(startIndex));
    }

    if (question.trim().isNotEmpty) {
      final last = messages.isNotEmpty ? messages.last : null;
      if (last == null || last['role'] != 'user' || last['content'] != question.trim()) {
        messages.add({
          'role': 'user',
          'content': question.trim(),
        });
      }
    }

    return messages;
  }

  /// Parses the Gemini response to extract Bible answer and references
  BibleQAResponse _parseBibleResponse(String response) {
    try {
      final normalizedResponse = _normalizeModelText(response);
      // Extract answer (everything before references)
      String answer;
      List<BibleReference> references = [];

      // Look for references section
      final lines = normalizedResponse.split('\n');
      List<String> answerLines = [];
      List<String> referenceLines = [];
      bool inReferencesSection = false;

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.toLowerCase().contains('references:') ||
            trimmedLine.toLowerCase().contains('referenties:')) {
          inReferencesSection = true;
          continue;
        }

        if (inReferencesSection) {
          referenceLines.add(trimmedLine);
        } else {
          answerLines.add(trimmedLine);
        }
      }

      answer = answerLines.where((line) => line.isNotEmpty).join('\n').trim();

      // Parse references
      for (final line in referenceLines) {
        final refs = _extractBibleReferences(line);
        references.addAll(refs);
      }

      // If no references found in dedicated section, try to extract from entire response
      if (references.isEmpty) {
        references = _extractBibleReferences(normalizedResponse);
      }

      return BibleQAResponse(
        answer: answer.isNotEmpty ? answer : normalizedResponse,
        references: references,
      );
    } catch (e) {
      AppLogger.warning('Failed to parse Bible response, using raw response: $e');
      return BibleQAResponse(
        answer: _normalizeModelText(response),
        references: [],
      );
    }
  }

  String _normalizeModelText(String text) {
    // Some fallbacks extract escaped sequences like "\\n" literally. Normalize them.
    return text
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t');
  }

  /// Extracts Bible references from text using regex patterns
  List<BibleReference> _extractBibleReferences(String text) {
    List<BibleReference> references = [];

    // Dutch Bible book name mappings for common abbreviations
    final Map<String, String> bookAbbreviations = {
      // Old Testament abbreviations
      'Gen': 'Genesis',
      'Ex': 'Exodus',
      'Exo': 'Exodus',
      'Lev': 'Leviticus',
      'Num': 'Numeri',
      'Deut': 'Deuteronomium',
      'Joz': 'Jozua',
      'Josh': 'Jozua',
      'Rech': 'Richteren',
      'Ruth': 'Ruth',
      '1 Sam': '1 Samuel',
      '2 Sam': '2 Samuel',
      '1 Kon': '1 Koningen',
      '2 Kon': '2 Koningen',
      '1 Kron': '1 Kronieken',
      '2 Kron': '2 Kronieken',
      'Ezr': 'Ezra',
      'Neh': 'Nehemia',
      'Est': 'Ester',
      'Job': 'Job',
      'Ps': 'Psalmen',
      'Spr': 'Spreuken',
      'Pred': 'Prediker',
      'Ecc': 'Prediker',
      'Hoogl': 'Hooglied',
      'Jes': 'Jesaja',
      'Jer': 'Jeremia',
      'Klaagl': 'Klaagliederen',
      'Ezech': 'Ezechiel',
      'Eze': 'Ezechiel',
      'Dan': 'Daniel',
      'Hos': 'Hosea',
      'Joel': 'Joël',
      'Joël': 'Joël',
      'Am': 'Amos',
      'Ob': 'Obadja',
      'Jon': 'Jona',
      'Mic': 'Micha',
      'Nah': 'Nahum',
      'Hab': 'Habakuk',
      'Zef': 'Zefanja',
      'Hag': 'Haggai',
      'Zach': 'Zacharia',
      'Mal': 'Maleachi',

      // New Testament abbreviations
      'Matt': 'Matteus',
      'Mt': 'Matteus',
      'Mark': 'Marcus',
      'Mk': 'Marcus',
      'Luk': 'Lukas',
      'Lk': 'Lukas',
      'Joh': 'Johannes',
      'Jn': 'Johannes',
      'Hand': 'Handelingen',
      'Acts': 'Handelingen',
      'Rom': 'Romeinen',
      '1 Kor': '1 Korintiers',
      '2 Kor': '2 Korintiers',
      'Gal': 'Galaten',
      'Ef': 'Efeziers',
      'Eph': 'Efeziers',
      'Fil': 'Filippenzen',
      'Phil': 'Filippenzen',
      'Kol': 'Kolossenzen',
      'Col': 'Kolossenzen',
      '1 Tess': '1 Tessalonicenzen',
      '2 Tess': '2 Tessalonicenzen',
      '1 Tim': '1 Timoteus',
      '2 Tim': '2 Timoteus',
      'Tit': 'Titus',
      'Film': 'Filemon',
      'Phlm': 'Filemon',
      'Hebr': 'Hebreeen',
      'Heb': 'Hebreeen',
      'Jak': 'Jakobus',
      'Jas': 'Jakobus',
      '1 Petr': '1 Petrus',
      '2 Petr': '2 Petrus',
      '1 Joh': '1 Johannes',
      '2 Joh': '2 Johannes',
      '3 Joh': '3 Johannes',
      'Jud': 'Judas',
      'Openb': 'Openbaring',
      'Rev': 'Openbaring',
    };

    // Common Bible reference patterns - improved to handle more cases
    final patterns = [
      // Genesis 1:1, Genesis 1:1-3 (full names and longer abbreviations)
      RegExp(r'([A-Za-z]+)\s+(\d+):(\d+)(?:-(\d+))?'),
      // Gen 1:1, Mic 1:1-3 (shorter abbreviations)
      RegExp(r'([A-Za-z]{2,10})\s+(\d+):(\d+)(?:-(\d+))?'),
      // Handle cases with periods like Gen. 1:1
      RegExp(r'([A-Za-z]+)\.?\s+(\d+):(\d+)(?:-(\d+))?'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);

      for (final match in matches) {
        if (match.groupCount >= 3) {
          String book = match.group(1) ?? '';
          final chapter = int.tryParse(match.group(2) ?? '0') ?? 0;
          final verse = int.tryParse(match.group(3) ?? '0') ?? 0;
          final endVerse = match.group(4) != null ? int.tryParse(match.group(4)!) : null;

          if (book.isNotEmpty && chapter > 0 && verse > 0) {
            // Convert abbreviation to full book name if needed
            String fullBookName = book;
            if (bookAbbreviations.containsKey(book)) {
              fullBookName = bookAbbreviations[book]!;
            } else {
              // Try case-insensitive matching
              for (final entry in bookAbbreviations.entries) {
                if (entry.key.toLowerCase() == book.toLowerCase()) {
                  fullBookName = entry.value;
                  break;
                }
              }
            }

            // Additional validation - ensure we have a valid book name
            if (fullBookName.length >= 2 && !_isNumeric(fullBookName)) {
              references.add(BibleReference(
                book: fullBookName,
                chapter: chapter,
                verse: verse,
                endVerse: endVerse,
              ));
            }
          }
        }
      }
    }

    // Remove duplicates by creating a set of reference strings and converting back
    final uniqueReferences = <String>{};
    final filteredReferences = <BibleReference>[];

    for (final ref in references) {
      final refString = ref.toString();
      if (uniqueReferences.add(refString)) {
        filteredReferences.add(ref);
      }
    }

    return filteredReferences;
  }

  /// Public wrapper to extract references from text
  List<BibleReference> extractBibleReferences(String text) {
    final normalized = _normalizeModelText(text);
    return _extractBibleReferences(normalized);
  }

  /// Helper method to check if a string is numeric
  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  /// Makes a streaming HTTP request to the Ollama API
  Future<Stream<String>> _makeStreamingApiRequestStream(
    String question, {
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) async {
    final url = Uri.parse('${AiConfig.baseUrl}/api/chat');

    final requestBody = json.encode({
      'model': 'ministral-3:14b-cloud', // Use the cloud model as specified in the API key
      'messages': _buildMessages(question, history, promptSettings),
      'stream': true
    });

    AppLogger.info('Making streaming request to Ollama API');

    final headers = {
      'Content-Type': 'application/json',
    };

    // Only add Authorization header if we have an API key
    if (_apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = requestBody;

    final streamed = await _httpClient.send(request).timeout(AiConfig.requestTimeout);

    return streamed.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.trim().isNotEmpty)
        .where((data) => data != '[DONE]')
        .map((data) {
          try {
            final jsonData = json.decode(data);
            final message = jsonData['message'] as Map<String, dynamic>?;
            final content = message?['content'] as String?;
            return content ?? '';
          } catch (e) {
            return '';
          }
        })
        .where((content) => content.isNotEmpty);
  }

  /// Disposes of resources used by the service
  void dispose() {
    _httpClient.close();
    _instance = null;
    AppLogger.info('AI service disposed');
  }
}
