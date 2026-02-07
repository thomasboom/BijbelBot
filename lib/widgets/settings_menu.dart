import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_chat_provider.dart';
import '../models/ai_prompt_settings.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => _showSettingsBottomSheet(context),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Consumer<BibleChatProvider>(
            builder: (context, provider, _) {
              final settings = provider.promptSettings;

              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      'AI-instellingen',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _sectionTitle('Toon'),
                  ...PromptTone.values.map((tone) {
                    return RadioListTile<PromptTone>(
                      value: tone,
                      groupValue: settings.tone,
                      title: Text(AiPromptSettings.toneLabel(tone)),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setPromptTone(value);
                        }
                      },
                    );
                  }),
                  _sectionTitle('Emoji\'s'),
                  ...EmojiLevel.values.map((level) {
                    return RadioListTile<EmojiLevel>(
                      value: level,
                      groupValue: settings.emojiLevel,
                      title: Text(AiPromptSettings.emojiLabel(level)),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setEmojiLevel(value);
                        }
                      },
                    );
                  }),
                  _sectionTitle('Antwoordformaat'),
                  ...ResponseFormat.values.map((format) {
                    return RadioListTile<ResponseFormat>(
                      value: format,
                      groupValue: settings.responseFormat,
                      title: Text(AiPromptSettings.formatLabel(format)),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setResponseFormat(value);
                        }
                      },
                    );
                  }),
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Verwijder alle gesprekken',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showDeleteAllChatsDialog(context, provider);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showDeleteAllChatsDialog(BuildContext context, BibleChatProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alle gesprekken verwijderen'),
          content: const Text(
            'Weet u zeker dat u alle gesprekken wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await provider.clearAllData();
                
                // Show confirmation
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alle gesprekken zijn verwijderd'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Verwijderen', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
