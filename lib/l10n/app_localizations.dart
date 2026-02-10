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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BijbelBot'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @biblicalReference.
  ///
  /// In en, this message translates to:
  /// **'Biblical Reference'**
  String get biblicalReference;

  /// No description provided for @invalidBiblicalReference.
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference'**
  String get invalidBiblicalReference;

  /// No description provided for @errorLoadingBiblicalText.
  ///
  /// In en, this message translates to:
  /// **'Error loading biblical text'**
  String get errorLoadingBiblicalText;

  /// No description provided for @errorLoadingWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading:'**
  String get errorLoadingWithDetails;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Timeout loading biblical text. Please try again later.'**
  String get timeoutError;

  /// No description provided for @invalidApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid API URL'**
  String get invalidApiUrl;

  /// No description provided for @invalidContentType.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get invalidContentType;

  /// No description provided for @xmlParsingFailed.
  ///
  /// In en, this message translates to:
  /// **'XML parsing failed and no text found'**
  String get xmlParsingFailed;

  /// No description provided for @noTextFound.
  ///
  /// In en, this message translates to:
  /// **'No text found in XML after parsing'**
  String get noTextFound;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Error loading biblical text (status:'**
  String get serverError;

  /// No description provided for @newBibleChat.
  ///
  /// In en, this message translates to:
  /// **'New Bible Chat'**
  String get newBibleChat;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// No description provided for @openConversations.
  ///
  /// In en, this message translates to:
  /// **'Open conversations'**
  String get openConversations;

  /// No description provided for @bibleBot.
  ///
  /// In en, this message translates to:
  /// **'BijbelBot'**
  String get bibleBot;

  /// No description provided for @errorInitializing.
  ///
  /// In en, this message translates to:
  /// **'Error initializing: '**
  String get errorInitializing;

  /// No description provided for @errorCreatingConversation.
  ///
  /// In en, this message translates to:
  /// **'Error creating conversation: '**
  String get errorCreatingConversation;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get noConversations;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @startNewConversationToAppear.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation to appear here'**
  String get startNewConversationToAppear;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiSettings;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @ollamaApiKey.
  ///
  /// In en, this message translates to:
  /// **'Ollama API Key'**
  String get ollamaApiKey;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @tone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get tone;

  /// No description provided for @emojis.
  ///
  /// In en, this message translates to:
  /// **'Emojis'**
  String get emojis;

  /// No description provided for @responseFormat.
  ///
  /// In en, this message translates to:
  /// **'Response Format'**
  String get responseFormat;

  /// No description provided for @customInstruction.
  ///
  /// In en, this message translates to:
  /// **'Custom Instruction'**
  String get customInstruction;

  /// No description provided for @writeExtraInstructions.
  ///
  /// In en, this message translates to:
  /// **'Write extra instructions for the AI...'**
  String get writeExtraInstructions;

  /// No description provided for @deleteAllConversations.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations'**
  String get deleteAllConversations;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get select;

  /// No description provided for @deleteAllConversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations'**
  String get deleteAllConversationsTitle;

  /// No description provided for @deleteAllConversationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all conversations? This action cannot be undone.'**
  String get deleteAllConversationsConfirm;

  /// No description provided for @allConversationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All conversations have been deleted'**
  String get allConversationsDeleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @setApiKey.
  ///
  /// In en, this message translates to:
  /// **'Set API Key'**
  String get setApiKey;

  /// No description provided for @enterApiKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your Ollama API key to use the chat. The key is only stored locally on this device.'**
  String get enterApiKeyDescription;

  /// No description provided for @storedLocallyOnly.
  ///
  /// In en, this message translates to:
  /// **'Stored locally only'**
  String get storedLocallyOnly;

  /// No description provided for @showKey.
  ///
  /// In en, this message translates to:
  /// **'Show key'**
  String get showKey;

  /// No description provided for @hideKey.
  ///
  /// In en, this message translates to:
  /// **'Hide key'**
  String get hideKey;

  /// No description provided for @enterValidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid API key.'**
  String get enterValidApiKey;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @invalidBiblicalReferenceWithRef.
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference: \"{reference}\"'**
  String invalidBiblicalReferenceWithRef(Object reference);

  /// No description provided for @invalidBookName.
  ///
  /// In en, this message translates to:
  /// **'Invalid book name: \"{book}\". Valid books: {books}...'**
  String invalidBookName(Object book, Object books);

  /// No description provided for @errorProcessingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred while processing your question. Please try again.'**
  String get errorProcessingQuestion;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noInternetConnection;

  /// No description provided for @couldNotInitializeChat.
  ///
  /// In en, this message translates to:
  /// **'Could not initialize chat: {error}'**
  String couldNotInitializeChat(Object error);

  /// No description provided for @addApiKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add your API key in the settings first.'**
  String get addApiKeyFirst;

  /// No description provided for @responseTakingLonger.
  ///
  /// In en, this message translates to:
  /// **'The response is taking longer than expected. Please try again.'**
  String get responseTakingLonger;

  /// No description provided for @confirmNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new conversation? The current conversation will be cleared.'**
  String get confirmNewConversation;

  /// No description provided for @couldNotStartNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Could not start new conversation: {error}'**
  String couldNotStartNewConversation(Object error);

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API Key Required'**
  String get apiKeyRequired;

  /// No description provided for @addApiKeyToUseChat.
  ///
  /// In en, this message translates to:
  /// **'Add your own Ollama API key to use the chat. You can change this later in the settings.'**
  String get addApiKeyToUseChat;

  /// No description provided for @addApiKey.
  ///
  /// In en, this message translates to:
  /// **'Add API Key'**
  String get addApiKey;

  /// No description provided for @initializingBibleChat.
  ///
  /// In en, this message translates to:
  /// **'Initializing Bible Chat...'**
  String get initializingBibleChat;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @sampleQuestion1.
  ///
  /// In en, this message translates to:
  /// **'What does the Bible say about forgiveness?'**
  String get sampleQuestion1;

  /// No description provided for @sampleQuestion2.
  ///
  /// In en, this message translates to:
  /// **'Explain the parable of the prodigal son'**
  String get sampleQuestion2;

  /// No description provided for @sampleQuestion3.
  ///
  /// In en, this message translates to:
  /// **'What is the meaning of John 3:16?'**
  String get sampleQuestion3;

  /// No description provided for @askQuestionAboutBible.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about the Bible...'**
  String get askQuestionAboutBible;

  /// No description provided for @warm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get warm;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @functional.
  ///
  /// In en, this message translates to:
  /// **'Functional'**
  String get functional;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @formatted.
  ///
  /// In en, this message translates to:
  /// **'Formatted'**
  String get formatted;

  /// No description provided for @longText.
  ///
  /// In en, this message translates to:
  /// **'Long text'**
  String get longText;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. Always verify important information. No AI response replaces personal Bible study and prayer.'**
  String get aiDisclaimer;
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
