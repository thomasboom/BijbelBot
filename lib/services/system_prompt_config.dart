class SystemPromptConfig {
  final String systemPrompt;
  final String responseStructure;
  final StyleInstructions styleInstructions;

  const SystemPromptConfig({
    required this.systemPrompt,
    required this.responseStructure,
    required this.styleInstructions,
  });

  factory SystemPromptConfig.fromJson(Map<String, dynamic> json) {
    return SystemPromptConfig(
      systemPrompt: json['system_prompt'] as String? ?? '',
      responseStructure: json['response_structure'] as String? ?? '',
      styleInstructions: StyleInstructions.fromJson(
        json['style_instructions'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_prompt': systemPrompt,
      'response_structure': responseStructure,
      'style_instructions': styleInstructions.toJson(),
    };
  }
}

class StyleInstructions {
  final Map<String, String> tone;
  final Map<String, String> emoji;
  final Map<String, String> format;

  const StyleInstructions({
    required this.tone,
    required this.emoji,
    required this.format,
  });

  factory StyleInstructions.fromJson(Map<String, dynamic> json) {
    return StyleInstructions(
      tone: Map<String, String>.from(json['tone'] as Map? ?? {}),
      emoji: Map<String, String>.from(json['emoji'] as Map? ?? {}),
      format: Map<String, String>.from(json['format'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tone': tone, 'emoji': emoji, 'format': format};
  }
}
