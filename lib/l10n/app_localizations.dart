import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'BijbelBot'**
  String get appName;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for biblical reference input
  ///
  /// In en, this message translates to:
  /// **'Biblical Reference'**
  String get biblicalReference;

  /// Error message for invalid biblical reference
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference'**
  String get invalidBiblicalReference;

  /// Error message when biblical text fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading biblical text'**
  String get errorLoadingBiblicalText;

  /// Error message prefix with details
  ///
  /// In en, this message translates to:
  /// **'Error loading:'**
  String get errorLoadingWithDetails;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get networkError;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Timeout loading biblical text. Please try again later.'**
  String get timeoutError;

  /// Invalid API URL error
  ///
  /// In en, this message translates to:
  /// **'Invalid API URL'**
  String get invalidApiUrl;

  /// Invalid content type error
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get invalidContentType;

  /// XML parsing error
  ///
  /// In en, this message translates to:
  /// **'XML parsing failed and no text found'**
  String get xmlParsingFailed;

  /// No text found error
  ///
  /// In en, this message translates to:
  /// **'No text found in XML after parsing'**
  String get noTextFound;

  /// Rate limit error
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// Server error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error loading biblical text (status:'**
  String get serverError;

  /// New Bible Chat button label
  ///
  /// In en, this message translates to:
  /// **'New Bible Chat'**
  String get newBibleChat;

  /// New conversation button label
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// Open conversations button label
  ///
  /// In en, this message translates to:
  /// **'Open conversations'**
  String get openConversations;

  /// BibleBot name
  ///
  /// In en, this message translates to:
  /// **'BijbelBot'**
  String get bibleBot;

  /// Error initializing message
  ///
  /// In en, this message translates to:
  /// **'Error initializing: '**
  String get errorInitializing;

  /// Error creating conversation message
  ///
  /// In en, this message translates to:
  /// **'Error creating conversation: '**
  String get errorCreatingConversation;

  /// Conversations section title
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// Search conversations placeholder
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No conversations message
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get noConversations;

  /// Try different search term hint
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// Hint to start new conversation
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation to appear here'**
  String get startNewConversationToAppear;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Settings menu label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// AI Settings section title
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiSettings;

  /// API Key label
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// Ollama API Key label
  ///
  /// In en, this message translates to:
  /// **'Ollama API Key'**
  String get ollamaApiKey;

  /// Set button label
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// Not set status
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Change button label
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Tone setting label
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get tone;

  /// Emojis setting label
  ///
  /// In en, this message translates to:
  /// **'Emojis'**
  String get emojis;

  /// Response Format setting label
  ///
  /// In en, this message translates to:
  /// **'Response Format'**
  String get responseFormat;

  /// Custom Instruction setting label
  ///
  /// In en, this message translates to:
  /// **'Custom Instruction'**
  String get customInstruction;

  /// Write extra instructions placeholder
  ///
  /// In en, this message translates to:
  /// **'Write extra instructions for the AI...'**
  String get writeExtraInstructions;

  /// Delete all conversations button label
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations'**
  String get deleteAllConversations;

  /// Warning that action cannot be undone
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// Select button label
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get select;

  /// Delete all conversations dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations'**
  String get deleteAllConversationsTitle;

  /// Delete all conversations confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all conversations? This action cannot be undone.'**
  String get deleteAllConversationsConfirm;

  /// All conversations deleted success message
  ///
  /// In en, this message translates to:
  /// **'All conversations have been deleted'**
  String get allConversationsDeleted;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Set API Key button label
  ///
  /// In en, this message translates to:
  /// **'Set API Key'**
  String get setApiKey;

  /// API key entry description
  ///
  /// In en, this message translates to:
  /// **'Enter your Ollama API key to use the chat. The key is only stored locally on this device.'**
  String get enterApiKeyDescription;

  /// Stored locally only label
  ///
  /// In en, this message translates to:
  /// **'Stored locally only'**
  String get storedLocallyOnly;

  /// Show key button label
  ///
  /// In en, this message translates to:
  /// **'Show key'**
  String get showKey;

  /// Hide key button label
  ///
  /// In en, this message translates to:
  /// **'Hide key'**
  String get hideKey;

  /// Enter valid API key validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid API key.'**
  String get enterValidApiKey;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Invalid biblical reference error with reference placeholder
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference: \"{reference}\"'**
  String invalidBiblicalReferenceWithRef(String reference);

  /// Invalid book name error with book and books placeholders
  ///
  /// In en, this message translates to:
  /// **'Invalid book name: \"{book}\". Valid books: {books}...'**
  String invalidBookName(String book, String books);

  /// Error processing question message
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred while processing your question. Please try again.'**
  String get errorProcessingQuestion;

  /// No internet connection error
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noInternetConnection;

  /// Could not initialize chat error with error placeholder
  ///
  /// In en, this message translates to:
  /// **'Could not initialize chat: {error}'**
  String couldNotInitializeChat(String error);

  /// Add API key first message
  ///
  /// In en, this message translates to:
  /// **'Please add your API key in the settings first.'**
  String get addApiKeyFirst;

  /// Response taking longer message
  ///
  /// In en, this message translates to:
  /// **'The response is taking longer than expected. Please try again.'**
  String get responseTakingLonger;

  /// Confirm new conversation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new conversation? The current conversation will be cleared.'**
  String get confirmNewConversation;

  /// Could not start new conversation error with error placeholder
  ///
  /// In en, this message translates to:
  /// **'Could not start new conversation: {error}'**
  String couldNotStartNewConversation(String error);

  /// API Key Required title
  ///
  /// In en, this message translates to:
  /// **'API Key Required'**
  String get apiKeyRequired;

  /// Add API key to use chat message
  ///
  /// In en, this message translates to:
  /// **'Add your own Ollama API key to use the chat. You can change this later in the settings.'**
  String get addApiKeyToUseChat;

  /// Add API Key button label
  ///
  /// In en, this message translates to:
  /// **'Add API Key'**
  String get addApiKey;

  /// Initializing Bible Chat message
  ///
  /// In en, this message translates to:
  /// **'Initializing Bible Chat...'**
  String get initializingBibleChat;

  /// Start conversation button label
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// Sample question 1
  ///
  /// In en, this message translates to:
  /// **'What does the Bible say about forgiveness?'**
  String get sampleQuestion1;

  /// Sample question 2
  ///
  /// In en, this message translates to:
  /// **'Explain the parable of the prodigal son'**
  String get sampleQuestion2;

  /// Sample question 3
  ///
  /// In en, this message translates to:
  /// **'What is the meaning of John 3:16?'**
  String get sampleQuestion3;

  /// Ask question about Bible placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask a question about the Bible...'**
  String get askQuestionAboutBible;

  /// Warm tone option
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get warm;

  /// Professional tone option
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// Functional tone option
  ///
  /// In en, this message translates to:
  /// **'Functional'**
  String get functional;

  /// More option
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Normal option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Less option
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// Formatted option
  ///
  /// In en, this message translates to:
  /// **'Formatted'**
  String get formatted;

  /// Long text option
  ///
  /// In en, this message translates to:
  /// **'Long text'**
  String get longText;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Microphone button label
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// AI disclaimer message
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. Always verify important information. No AI response replaces personal Bible study and prayer.'**
  String get aiDisclaimer;

  /// Disclaimer label
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// Full disclaimer text
  ///
  /// In en, this message translates to:
  /// **'This application is a tool designed to assist with biblical study and reflection. It is NOT a replacement for personal prayer, spiritual guidance, or your relationship with God. AI responses may contain errors or inaccuracies. Always verify important information with your own Bible study and prayer. This tool cannot replace the Holy Spirit\'s guidance in your life. The developers are not responsible for any decisions made based on AI-generated content. Remember: this is a tool, not a god.'**
  String get disclaimerText;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Dutch language option
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Rename button label
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Rename conversation button label
  ///
  /// In en, this message translates to:
  /// **'Rename conversation'**
  String get renameConversation;

  /// Delete conversation button label
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// Delete conversation confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation? This action cannot be undone.'**
  String get deleteConversationConfirm;

  /// Conversation deleted success message
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Conversation renamed success message
  ///
  /// In en, this message translates to:
  /// **'Conversation renamed'**
  String get conversationRenamed;

  /// Enter new title placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter new title'**
  String get enterNewTitle;

  /// Pin button label
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Unpin button label
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Conversation pinned success message
  ///
  /// In en, this message translates to:
  /// **'Conversation pinned'**
  String get conversationPinned;

  /// Conversation unpinned success message
  ///
  /// In en, this message translates to:
  /// **'Conversation unpinned'**
  String get conversationUnpinned;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Edit prompt button label
  ///
  /// In en, this message translates to:
  /// **'Edit prompt'**
  String get editPrompt;

  /// Edit prompt dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit your message'**
  String get editPromptTitle;

  /// Edit prompt dialog description
  ///
  /// In en, this message translates to:
  /// **'Edit your message. The conversation will restart from this point.'**
  String get editPromptDescription;

  /// Edit prompt input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your message...'**
  String get editPromptHint;

  /// Message edited success message
  ///
  /// In en, this message translates to:
  /// **'Message edited'**
  String get messageEdited;

  /// Restart conversation button label
  ///
  /// In en, this message translates to:
  /// **'Restart conversation'**
  String get restartConversation;

  /// Restart conversation confirmation message
  ///
  /// In en, this message translates to:
  /// **'Editing this message will restart the conversation from this point. All messages after this one will be removed. Continue?'**
  String get restartConversationConfirm;

  /// AI Model setting label
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// Low cost model option
  ///
  /// In en, this message translates to:
  /// **'Low Cost'**
  String get lowCostModel;

  /// Medium cost model option
  ///
  /// In en, this message translates to:
  /// **'Medium Cost'**
  String get mediumCostModel;

  /// High cost model option
  ///
  /// In en, this message translates to:
  /// **'High Cost'**
  String get highCostModel;

  /// Model selection description
  ///
  /// In en, this message translates to:
  /// **'Choose the AI model to use. Higher cost models provide better quality but may be slower and more expensive.'**
  String get modelDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
