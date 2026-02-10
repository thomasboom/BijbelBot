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

  @override
  String get conversations => 'Gesprekken';

  @override
  String get searchConversations => 'Zoek gesprekken...';

  @override
  String get noResults => 'Geen resultaten';

  @override
  String get noConversations => 'Geen gesprekken';

  @override
  String get tryDifferentSearchTerm => 'Probeer een andere zoekterm';

  @override
  String get startNewConversationToAppear =>
      'Begin een nieuw gesprek om hier te verschijnen';

  @override
  String get today => 'Vandaag';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get monday => 'Ma';

  @override
  String get tuesday => 'Di';

  @override
  String get wednesday => 'Wo';

  @override
  String get thursday => 'Do';

  @override
  String get friday => 'Vr';

  @override
  String get saturday => 'Za';

  @override
  String get sunday => 'Zo';

  @override
  String get settings => 'Instellingen';

  @override
  String get aiSettings => 'AI-instellingen';

  @override
  String get apiKey => 'API key';

  @override
  String get ollamaApiKey => 'Ollama API key';

  @override
  String get set => 'Ingesteld';

  @override
  String get notSet => 'Niet ingesteld';

  @override
  String get change => 'Wijzigen';

  @override
  String get add => 'Toevoegen';

  @override
  String get tone => 'Toon';

  @override
  String get emojis => 'Emoji\'s';

  @override
  String get responseFormat => 'Antwoordformaat';

  @override
  String get customInstruction => 'Eigen instructie';

  @override
  String get writeExtraInstructions =>
      'Schrijf extra instructies voor de AI...';

  @override
  String get deleteAllConversations => 'Verwijder alle gesprekken';

  @override
  String get thisActionCannotBeUndone =>
      'Deze actie kan niet ongedaan worden gemaakt';

  @override
  String get select => 'Selecteer...';

  @override
  String get deleteAllConversationsTitle => 'Alle gesprekken verwijderen';

  @override
  String get deleteAllConversationsConfirm =>
      'Weet u zeker dat u alle gesprekken wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get allConversationsDeleted => 'Alle gesprekken zijn verwijderd';

  @override
  String get delete => 'Verwijderen';

  @override
  String get setApiKey => 'API key instellen';

  @override
  String get enterApiKeyDescription =>
      'Voer je Ollama API key in om de chat te gebruiken. De key wordt alleen lokaal opgeslagen op dit apparaat.';

  @override
  String get storedLocallyOnly => 'Wordt alleen lokaal opgeslagen';

  @override
  String get showKey => 'Toon key';

  @override
  String get hideKey => 'Verberg key';

  @override
  String get enterValidApiKey => 'Vul een geldige API key in.';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Annuleren';

  @override
  String invalidBiblicalReferenceWithRef(Object reference) {
    return 'Ongeldige bijbelverwijzing: \"$reference\"';
  }

  @override
  String invalidBookName(Object book, Object books) {
    return 'Ongeldig boeknaam: \"$book\". Geldige boeken: $books...';
  }

  @override
  String get errorProcessingQuestion =>
      'Sorry, er is een fout opgetreden bij het verwerken van uw vraag. Probeer opnieuw.';

  @override
  String get noInternetConnection =>
      'Geen internetverbinding. Controleer uw netwerk en probeer opnieuw.';

  @override
  String couldNotInitializeChat(Object error) {
    return 'Kon chat niet initialiseren: $error';
  }

  @override
  String get addApiKeyFirst => 'Voeg eerst je API key toe in de instellingen.';

  @override
  String get responseTakingLonger =>
      'De reactie duurt langer dan verwacht. Probeer het opnieuw.';

  @override
  String get confirmNewConversation =>
      'Weet je zeker dat je een nieuwe conversatie wilt starten? De huidige conversatie wordt gewist.';

  @override
  String couldNotStartNewConversation(Object error) {
    return 'Kon nieuwe conversatie niet starten: $error';
  }

  @override
  String get apiKeyRequired => 'API key vereist';

  @override
  String get addApiKeyToUseChat =>
      'Voeg je eigen Ollama API key toe om de chat te gebruiken. Je kunt dit later wijzigen in de instellingen.';

  @override
  String get addApiKey => 'API key toevoegen';

  @override
  String get initializingBibleChat => 'Bijbel Chat initialiseren...';

  @override
  String get startConversation => 'Start een gesprek';

  @override
  String get sampleQuestion1 => 'Wat zegt de Bijbel over vergeving?';

  @override
  String get sampleQuestion2 => 'Leg de gelijkenis van de verloren zoon uit';

  @override
  String get sampleQuestion3 => 'Wat is de betekenis van Johannes 3:16?';

  @override
  String get askQuestionAboutBible => 'Stel een vraag over de Bijbel...';

  @override
  String get warm => 'Warm';

  @override
  String get professional => 'Professioneel';

  @override
  String get functional => 'Functioneel';

  @override
  String get more => 'Meer';

  @override
  String get normal => 'Normaal';

  @override
  String get less => 'Minder';

  @override
  String get formatted => 'Geformatteerd';

  @override
  String get longText => 'Lange tekst';

  @override
  String get retry => 'Opnieuw';

  @override
  String get microphone => 'Microfoon';
}
