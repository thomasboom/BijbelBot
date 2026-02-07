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
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colorScheme.surface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<BibleChatProvider>(
      builder: (context, provider, _) {
        final settings = provider.promptSettings;

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'AI-instellingen',
                style: textTheme.titleMedium,
              ),
            ),
            _sectionTitle('API key', textTheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.vpn_key, color: colorScheme.primary),
                title: Text('Ollama API key', style: textTheme.bodyLarge),
                subtitle: Text(
                  provider.hasApiKey
                      ? 'Ingesteld (${_maskApiKey(provider.apiKey!)})'
                      : 'Niet ingesteld',
                  style: textTheme.bodyMedium,
                ),
                trailing: TextButton(
                  onPressed: () => _showApiKeyDialog(context, provider),
                  child: Text(provider.hasApiKey ? 'Wijzigen' : 'Toevoegen'),
                ),
              ),
            ),
            _sectionTitle('Toon', textTheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<PromptTone>(
                value: settings.tone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: PromptTone.values
                    .map(
                      (tone) => DropdownMenuItem(
                        value: tone,
                        child: Text(AiPromptSettings.toneLabel(tone), style: textTheme.bodyLarge),
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
            _sectionTitle('Emoji\'s', textTheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<EmojiLevel>(
                value: settings.emojiLevel,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: EmojiLevel.values
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(AiPromptSettings.emojiLabel(level), style: textTheme.bodyLarge),
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
            _sectionTitle('Antwoordformaat', textTheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<ResponseFormat>(
                value: settings.responseFormat,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ResponseFormat.values
                    .map(
                      (format) => DropdownMenuItem(
                        value: format,
                        child: Text(AiPromptSettings.formatLabel(format), style: textTheme.bodyLarge),
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
            _sectionTitle('Eigen instructie', textTheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _customController,
                minLines: 3,
                maxLines: 6,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  hintText: 'Schrijf extra instructies voor de AI...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: provider.setCustomInstruction,
              ),
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: colorScheme.tertiary),
                title: Text(
                  'Verwijder alle gesprekken',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteAllChatsDialog(context, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: textTheme.labelLarge,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: colorScheme.surface,
          title: Text('Alle gesprekken verwijderen', style: textTheme.titleLarge),
          content: Text(
            'Weet u zeker dat u alle gesprekken wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.',
            style: textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuleren', style: textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.clearAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alle gesprekken zijn verwijderd', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
              child: Text(
                'Verwijderen',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.tertiary),
              ),
            ),
          ],
        );
      },
    );
  }
}
