// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BijbelBot';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get close => 'Close';

  @override
  String get biblicalReference => 'Biblical Reference';

  @override
  String get invalidBiblicalReference => 'Invalid biblical reference';

  @override
  String get errorLoadingBiblicalText => 'Error loading biblical text';

  @override
  String get errorLoadingWithDetails => 'Error loading:';

  @override
  String get networkError => 'Network error. Check your internet connection.';

  @override
  String get timeoutError =>
      'Timeout loading biblical text. Please try again later.';

  @override
  String get invalidApiUrl => 'Invalid API URL';

  @override
  String get invalidContentType => 'Invalid server response';

  @override
  String get xmlParsingFailed => 'XML parsing failed and no text found';

  @override
  String get noTextFound => 'No text found in XML after parsing';

  @override
  String get tooManyRequests => 'Too many requests. Please try again later.';

  @override
  String get serverError => 'Error loading biblical text (status:';

  @override
  String get newBibleChat => 'New Bible Chat';

  @override
  String get newConversation => 'New conversation';

  @override
  String get openConversations => 'Open conversations';

  @override
  String get bibleBot => 'BijbelBot';

  @override
  String get errorInitializing => 'Error initializing: ';

  @override
  String get errorCreatingConversation => 'Error creating conversation: ';

  @override
  String get conversations => 'Conversations';

  @override
  String get searchConversations => 'Search conversations...';

  @override
  String get noResults => 'No results';

  @override
  String get noConversations => 'No conversations';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get startNewConversationToAppear =>
      'Start a new conversation to appear here';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get settings => 'Settings';

  @override
  String get aiSettings => 'AI Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get ollamaApiKey => 'Ollama API Key';

  @override
  String get set => 'Set';

  @override
  String get notSet => 'Not set';

  @override
  String get change => 'Change';

  @override
  String get add => 'Add';

  @override
  String get tone => 'Tone';

  @override
  String get emojis => 'Emojis';

  @override
  String get responseFormat => 'Response Format';

  @override
  String get customInstruction => 'Custom Instruction';

  @override
  String get writeExtraInstructions => 'Write extra instructions for the AI...';

  @override
  String get deleteAllConversations => 'Delete all conversations';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone';

  @override
  String get select => 'Select...';

  @override
  String get deleteAllConversationsTitle => 'Delete all conversations';

  @override
  String get deleteAllConversationsConfirm =>
      'Are you sure you want to delete all conversations? This action cannot be undone.';

  @override
  String get allConversationsDeleted => 'All conversations have been deleted';

  @override
  String get delete => 'Delete';

  @override
  String get setApiKey => 'Set API Key';

  @override
  String get enterApiKeyDescription =>
      'Enter your Ollama API key to use the chat. The key is only stored locally on this device.';

  @override
  String get storedLocallyOnly => 'Stored locally only';

  @override
  String get showKey => 'Show key';

  @override
  String get hideKey => 'Hide key';

  @override
  String get enterValidApiKey => 'Please enter a valid API key.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String invalidBiblicalReferenceWithRef(Object reference) {
    return 'Invalid biblical reference: \"$reference\"';
  }

  @override
  String invalidBookName(Object book, Object books) {
    return 'Invalid book name: \"$book\". Valid books: $books...';
  }

  @override
  String get errorProcessingQuestion =>
      'Sorry, an error occurred while processing your question. Please try again.';

  @override
  String get noInternetConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String couldNotInitializeChat(Object error) {
    return 'Could not initialize chat: $error';
  }

  @override
  String get addApiKeyFirst => 'Please add your API key in the settings first.';

  @override
  String get responseTakingLonger =>
      'The response is taking longer than expected. Please try again.';

  @override
  String get confirmNewConversation =>
      'Are you sure you want to start a new conversation? The current conversation will be cleared.';

  @override
  String couldNotStartNewConversation(Object error) {
    return 'Could not start new conversation: $error';
  }

  @override
  String get apiKeyRequired => 'API Key Required';

  @override
  String get addApiKeyToUseChat =>
      'Add your own Ollama API key to use the chat. You can change this later in the settings.';

  @override
  String get addApiKey => 'Add API Key';

  @override
  String get initializingBibleChat => 'Initializing Bible Chat...';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get sampleQuestion1 => 'What does the Bible say about forgiveness?';

  @override
  String get sampleQuestion2 => 'Explain the parable of the prodigal son';

  @override
  String get sampleQuestion3 => 'What is the meaning of John 3:16?';

  @override
  String get askQuestionAboutBible => 'Ask a question about the Bible...';

  @override
  String get warm => 'Warm';

  @override
  String get professional => 'Professional';

  @override
  String get functional => 'Functional';

  @override
  String get more => 'More';

  @override
  String get normal => 'Normal';

  @override
  String get less => 'Less';

  @override
  String get formatted => 'Formatted';

  @override
  String get longText => 'Long text';

  @override
  String get retry => 'Retry';

  @override
  String get microphone => 'Microphone';

  @override
  String get aiDisclaimer =>
      'AI can make mistakes. Always verify important information. No AI response replaces personal Bible study and prayer.';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get disclaimerText =>
      'This application is a tool designed to assist with biblical study and reflection. It is NOT a replacement for personal prayer, spiritual guidance, or your relationship with God. AI responses may contain errors or inaccuracies. Always verify important information with your own Bible study and prayer. This tool cannot replace the Holy Spirit\'s guidance in your life. The developers are not responsible for any decisions made based on AI-generated content. Remember: this is a tool, not a god.';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get english => 'English';

  @override
  String get dutch => 'Dutch';

  @override
  String get rename => 'Rename';

  @override
  String get renameConversation => 'Rename conversation';

  @override
  String get deleteConversation => 'Delete conversation';

  @override
  String get deleteConversationConfirm =>
      'Are you sure you want to delete this conversation? This action cannot be undone.';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get conversationRenamed => 'Conversation renamed';

  @override
  String get enterNewTitle => 'Enter new title';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get conversationPinned => 'Conversation pinned';

  @override
  String get conversationUnpinned => 'Conversation unpinned';

  @override
  String get edit => 'Edit';

  @override
  String get editPrompt => 'Edit prompt';

  @override
  String get editPromptTitle => 'Edit your message';

  @override
  String get editPromptDescription =>
      'Edit your message. The conversation will restart from this point.';

  @override
  String get editPromptHint => 'Enter your message...';

  @override
  String get messageEdited => 'Message edited';

  @override
  String get restartConversation => 'Restart conversation';

  @override
  String get restartConversationConfirm =>
      'Editing this message will restart the conversation from this point. All messages after this one will be removed. Continue?';
}
