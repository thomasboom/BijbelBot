import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_chat_provider.dart';
import '../models/ai_prompt_settings.dart';
import 'api_key_dialog.dart';

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
        return const SettingsBottomSheetContent();
      },
    );
  }
}

class SettingsBottomSheetContent extends StatefulWidget {
  const SettingsBottomSheetContent({super.key});

  @override
  State<SettingsBottomSheetContent> createState() =>
      _SettingsBottomSheetContentState();
}

class _SettingsBottomSheetContentState
    extends State<SettingsBottomSheetContent> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final customInstruction = context
        .read<BibleChatProvider>()
        .promptSettings
        .customInstruction;
    _customController = TextEditingController(text: customInstruction);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleChatProvider>(
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
            _sectionTitle('API key'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.vpn_key),
                title: const Text('Ollama API key'),
                subtitle: Text(
                  provider.hasApiKey
                      ? 'Ingesteld (${_maskApiKey(provider.apiKey!)})'
                      : 'Niet ingesteld',
                ),
                trailing: TextButton(
                  onPressed: () => _showApiKeyDialog(context, provider),
                  child: Text(provider.hasApiKey ? 'Wijzigen' : 'Toevoegen'),
                ),
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
                controller: _customController,
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

  String _maskApiKey(String apiKey) {
    final trimmed = apiKey.trim();
    if (trimmed.length <= 4) return '****';
    final visible = trimmed.substring(trimmed.length - 4);
    return '****$visible';
  }

  void _showApiKeyDialog(
    BuildContext context,
    BibleChatProvider provider,
  ) async {
    await showApiKeyDialog(
      context: context,
      existingKey: provider.apiKey,
      onSave: (value) async {
        await provider.setApiKey(value);
      },
    );
  }

  void _showDeleteAllChatsDialog(
    BuildContext context,
    BibleChatProvider provider,
  ) {
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
                Navigator.of(context).pop();
                await provider.clearAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alle gesprekken zijn verwijderd'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Verwijderen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
