import '../services/logger.dart';
import 'gemini_service.dart';
import '../models/ai_prompt_settings.dart';

// Re-export types for convenience
export 'gemini_service.dart' show BibleReference, BibleQAResponse;

/// Service for handling Bible bot interactions
class BibleBotService {
  static BibleBotService? _instance;
  bool _isInitialized = false;

  static BibleBotService get instance {
    _instance ??= BibleBotService._();
    return _instance!;
  }

  BibleBotService._();

  bool get isInitialized => _isInitialized;

  /// Initialize the Bible bot service
  Future<void> initialize({required String apiKey}) async {
    try {
      AppLogger.info('Initializing BibleBot service...');

      // Initialize AI service
      await AiService.instance.initialize(apiKey: apiKey);

      _isInitialized = true;
      AppLogger.info('BibleBot service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize BibleBot service', e);
      throw Exception('Failed to initialize BibleBot service: $e');
    }
  }

  /// Ask a question to the Bible bot
  Future<BibleQAResponse> askQuestion({
    required String question,
    required String questionType,
    String? conversationId,
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) async {
    try {
      AppLogger.info('Asking Bible question: $question');

      // Use AI service to get Bible answer
      final response = await AiService.instance.askBibleQuestion(
        question,
        history: history,
        promptSettings: promptSettings,
      );

      return response;
    } catch (e) {
      AppLogger.error('Failed to get answer from Bible bot', e);
      throw Exception('Failed to get answer: $e');
    }
  }

  /// Ask a question to the Bible bot with streaming support
  Stream<String> askQuestionStream({
    required String question,
    List<Map<String, String>>? history,
    AiPromptSettings? promptSettings,
  }) {
    return AiService.instance.askBibleQuestionStream(
      question,
      history: history,
      promptSettings: promptSettings,
    );
  }

  /// Extract Bible references from a text response
  List<BibleReference> extractBibleReferences(String text) {
    return AiService.instance.extractBibleReferences(text);
  }
}
