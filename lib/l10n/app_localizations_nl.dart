// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'BijbelBot';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fout';

  @override
  String get close => 'Sluiten';

  @override
  String get biblicalReference => 'Bijbelverwijzing';

  @override
  String get invalidBiblicalReference => 'Ongeldige bijbelverwijzing';

  @override
  String get errorLoadingBiblicalText =>
      'Fout bij het laden van de bijbeltekst';

  @override
  String get errorLoadingWithDetails => 'Fout bij het laden:';

  @override
  String get networkError => 'Netwerkfout. Controleer uw internetverbinding.';

  @override
  String get timeoutError =>
      'Time-out bij het laden van de bijbeltekst. Probeer het later opnieuw.';

  @override
  String get invalidApiUrl => 'Ongeldige API URL';

  @override
  String get invalidContentType => 'Ongeldig antwoord van de server';

  @override
  String get xmlParsingFailed => 'XML parsing mislukt en geen tekst gevonden';

  @override
  String get noTextFound => 'Geen tekst gevonden in XML na parsing';

  @override
  String get tooManyRequests => 'Te veel verzoeken. Probeer het later opnieuw.';

  @override
  String get serverError => 'Fout bij het laden van de bijbeltekst (status:';

  @override
  String get newBibleChat => 'Nieuwe Bijbel Chat';

  @override
  String get newConversation => 'Nieuwe conversatie';

  @override
  String get openConversations => 'Open gesprekken';

  @override
  String get bibleBot => 'BijbelBot';

  @override
  String get errorInitializing => 'Fout bij initialiseren: ';

  @override
  String get errorCreatingConversation => 'Fout bij maken conversatie: ';
}
