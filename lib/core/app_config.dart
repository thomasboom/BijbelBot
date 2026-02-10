/// Application-wide configuration constants
class AppConfig {
  // App metadata
  static const String appName = 'BijbelBot';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String conversationsKey = 'bible_chat_conversations';
  static const String messagesKey = 'bible_chat_messages';
  static const String activeConversationKey = 'bible_chat_active_conversation';
  static const String promptToneKey = 'ai_prompt_tone';
  static const String promptEmojiKey = 'ai_prompt_emoji';
  static const String promptFormatKey = 'ai_prompt_format';
  static const String promptCustomKey = 'ai_prompt_custom';
  static const String apiKeyKey = 'ollama_api_key';
  static const String languageKey = 'app_language';
  static const String themeModeKey = 'app_theme_mode';
  static const String aiModelKey = 'ai_model';

  // Conversation settings
  static const Duration emptyConversationGracePeriod = Duration(minutes: 10);
  static const int titleHistoryLimit = 12;

  // UI settings
  static const double defaultDrawerWidth = 320.0;
  static const Duration scrollAnimationDuration = Duration(milliseconds: 250);
  static const Duration scrollDebounceDelay = Duration(milliseconds: 100);
  static const Duration requestTimeout = Duration(seconds: 45);
}
