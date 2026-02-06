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
}
