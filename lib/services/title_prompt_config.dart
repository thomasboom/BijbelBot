import 'dart:convert';
import 'package:flutter/services.dart';

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
