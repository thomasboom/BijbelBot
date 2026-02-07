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
    final customController = TextEditingController(
      text: context.read<BibleChatProvider>().promptSettings.customInstruction,
    );

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<PromptTone>(
                      value: settings.tone,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: PromptTone.values
                          .map(
                            (tone) => DropdownMenuItem(
                              value: tone,
                              child: Text(AiPromptSettings.toneLabel(tone)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setPromptTone(value);
                        }
                      },
                    ),
                  ),
                  _sectionTitle('Emoji\'s'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<EmojiLevel>(
                      value: settings.emojiLevel,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: EmojiLevel.values
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(AiPromptSettings.emojiLabel(level)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setEmojiLevel(value);
                        }
                      },
                    ),
                  ),
                  _sectionTitle('Antwoordformaat'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<ResponseFormat>(
                      value: settings.responseFormat,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: ResponseFormat.values
                          .map(
                            (format) => DropdownMenuItem(
                              value: format,
                              child: Text(AiPromptSettings.formatLabel(format)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setResponseFormat(value);
                        }
                      },
                    ),
                  ),
                  _sectionTitle('Eigen instructie'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: customController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Schrijf extra instructies voor de AI...',
                      ),
                      onChanged: provider.setCustomInstruction,
                    ),
                  ),
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
    ).whenComplete(customController.dispose);
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
