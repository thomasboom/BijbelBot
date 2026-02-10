import 'dart:convert';
import 'package:flutter/services.dart';

/// Configuration for the AI system prompt
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

  /// Loads the system prompt configuration from the assets JSON file
  static Future<SystemPromptConfig> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/system_prompt.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return SystemPromptConfig.fromJson(jsonData);
    } catch (e) {
      // Fallback to default prompt if loading fails
      return const SystemPromptConfig(
        systemPrompt: 'Je bent een behulpzame assistent.',
        responseStructure: '',
        styleInstructions: StyleInstructions(tone: {}, emoji: {}, format: {}),
      );
    }
  }
}

/// Style instructions for AI responses
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

/// Configuration for the AI title generation prompt
class TitlePromptConfig {
  final String titlePrompt;

  const TitlePromptConfig({required this.titlePrompt});

  factory TitlePromptConfig.fromJson(Map<String, dynamic> json) {
    return TitlePromptConfig(
      titlePrompt: json['title_prompt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title_prompt': titlePrompt};
  }

  /// Loads the title prompt configuration from the assets JSON file
  static Future<TitlePromptConfig> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/title_prompt.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return TitlePromptConfig.fromJson(jsonData);
    } catch (e) {
      // Fallback to default prompt if loading fails
      return const TitlePromptConfig(
        titlePrompt:
            'Geef een korte, duidelijke titel van exact één zin zonder vraagteken en zonder opsommingen of voortekens. Gebruik geen Markdown-opmaak, geen codeblokken, geen emoji\'s en verwijder speciale tekens zoals "#", "/", "`", "*", "-", "•" of bullets; schrijf alleen een normale zin met alledaagse woorden.',
      );
    }
  }
}
