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

  const AiPromptSettings({
    required this.tone,
    required this.emojiLevel,
    required this.responseFormat,
  });

  factory AiPromptSettings.defaults() {
    return const AiPromptSettings(
      tone: PromptTone.warm,
      emojiLevel: EmojiLevel.normal,
      responseFormat: ResponseFormat.formatted,
    );
  }

  AiPromptSettings copyWith({
    PromptTone? tone,
    EmojiLevel? emojiLevel,
    ResponseFormat? responseFormat,
  }) {
    return AiPromptSettings(
      tone: tone ?? this.tone,
      emojiLevel: emojiLevel ?? this.emojiLevel,
      responseFormat: responseFormat ?? this.responseFormat,
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

  static String toneLabel(PromptTone tone) {
    switch (tone) {
      case PromptTone.warm:
        return 'Warm';
      case PromptTone.professional:
        return 'Professioneel';
      case PromptTone.functional:
        return 'Functioneel';
    }
  }

  static String emojiLabel(EmojiLevel level) {
    switch (level) {
      case EmojiLevel.more:
        return 'Meer';
      case EmojiLevel.normal:
        return 'Normaal';
      case EmojiLevel.less:
        return 'Minder';
    }
  }

  static String formatLabel(ResponseFormat format) {
    switch (format) {
      case ResponseFormat.formatted:
        return 'Geformatteerd';
      case ResponseFormat.longText:
        return 'Lange tekst';
    }
  }
}
