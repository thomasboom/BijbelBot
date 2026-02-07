import '../l10n/app_localizations.dart';

enum PromptTone {
  warm,
  professional,
  functional,
}

enum EmojiLevel {
  more,
  normal,
  less,
}

enum ResponseFormat {
  formatted,
  longText,
}

class AiPromptSettings {
  final PromptTone tone;
  final EmojiLevel emojiLevel;
  final ResponseFormat responseFormat;
  final String customInstruction;

  const AiPromptSettings({
    required this.tone,
    required this.emojiLevel,
    required this.responseFormat,
    required this.customInstruction,
  });

  factory AiPromptSettings.defaults() {
    return const AiPromptSettings(
      tone: PromptTone.warm,
      emojiLevel: EmojiLevel.normal,
      responseFormat: ResponseFormat.formatted,
      customInstruction: '',
    );
  }

  AiPromptSettings copyWith({
    PromptTone? tone,
    EmojiLevel? emojiLevel,
    ResponseFormat? responseFormat,
    String? customInstruction,
  }) {
    return AiPromptSettings(
      tone: tone ?? this.tone,
      emojiLevel: emojiLevel ?? this.emojiLevel,
      responseFormat: responseFormat ?? this.responseFormat,
      customInstruction: customInstruction ?? this.customInstruction,
    );
  }

  static PromptTone parseTone(String? value) {
    switch (value) {
      case 'warm':
        return PromptTone.warm;
      case 'professional':
        return PromptTone.professional;
      case 'functional':
        return PromptTone.functional;
      default:
        return AiPromptSettings.defaults().tone;
    }
  }

  static EmojiLevel parseEmojiLevel(String? value) {
    switch (value) {
      case 'more':
        return EmojiLevel.more;
      case 'normal':
        return EmojiLevel.normal;
      case 'less':
        return EmojiLevel.less;
      default:
        return AiPromptSettings.defaults().emojiLevel;
    }
  }

  static ResponseFormat parseResponseFormat(String? value) {
    switch (value) {
      case 'formatted':
        return ResponseFormat.formatted;
      case 'longText':
        return ResponseFormat.longText;
      default:
        return AiPromptSettings.defaults().responseFormat;
    }
  }

  static String toneLabel(PromptTone tone, AppLocalizations localizations) {
    switch (tone) {
      case PromptTone.warm:
        return localizations.warm;
      case PromptTone.professional:
        return localizations.professional;
      case PromptTone.functional:
        return localizations.functional;
    }
  }

  static String emojiLabel(EmojiLevel level, AppLocalizations localizations) {
    switch (level) {
      case EmojiLevel.more:
        return localizations.more;
      case EmojiLevel.normal:
        return localizations.normal;
      case EmojiLevel.less:
        return localizations.less;
    }
  }

  static String formatLabel(ResponseFormat format, AppLocalizations localizations) {
    switch (format) {
      case ResponseFormat.formatted:
        return localizations.formatted;
      case ResponseFormat.longText:
        return localizations.longText;
    }
  }
}
