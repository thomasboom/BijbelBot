import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_chat_provider.dart';
import '../models/ai_prompt_settings.dart';
import 'api_key_dialog.dart';

/// M3 Expressive settings menu widget
/// 
/// Features:
/// - M3 bottom sheet with drag handle
/// - Dynamic color from theme colorScheme
/// - M3 shape system for components
/// - Expressive motion for interactions
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => _showSettingsBottomSheet(context),
      tooltip: 'Instellingen',
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true, // M3 drag handle
      isScrollControlled: true,
      useSafeArea: true,
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
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'AI-instellingen',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            
            // API Key Section
            _buildSectionTitle('API key', textTheme, colorScheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.vpn_key_outlined, color: colorScheme.primary),
                  title: Text('Ollama API key', style: textTheme.titleSmall),
                  subtitle: Text(
                    provider.hasApiKey
                        ? 'Ingesteld (${_maskApiKey(provider.apiKey!)})'
                        : 'Niet ingesteld',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => _showApiKeyDialog(context, provider),
                    child: Text(provider.hasApiKey ? 'Wijzigen' : 'Toevoegen'),
                  ),
                ),
              ),
            ),
            
            // Tone Section
            _buildSectionTitle('Toon', textTheme, colorScheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDropdown<PromptTone>(
                value: settings.tone,
                items: PromptTone.values,
                labelBuilder: AiPromptSettings.toneLabel,
                onChanged: provider.setPromptTone,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            
            // Emoji Section
            _buildSectionTitle('Emoji\'s', textTheme, colorScheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDropdown<EmojiLevel>(
                value: settings.emojiLevel,
                items: EmojiLevel.values,
                labelBuilder: AiPromptSettings.emojiLabel,
                onChanged: provider.setEmojiLevel,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            
            // Response Format Section
            _buildSectionTitle('Antwoordformaat', textTheme, colorScheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDropdown<ResponseFormat>(
                value: settings.responseFormat,
                items: ResponseFormat.values,
                labelBuilder: AiPromptSettings.formatLabel,
                onChanged: provider.setResponseFormat,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            
            // Custom Instruction Section
            _buildSectionTitle('Eigen instructie', textTheme, colorScheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: TextField(
                controller: _customController,
                minLines: 3,
                maxLines: 6,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Schrijf extra instructies voor de AI...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onChanged: provider.setCustomInstruction,
              ),
            ),
            
            // Danger Zone
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                margin: EdgeInsets.zero,
                color: colorScheme.errorContainer,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    'Verwijder alle gesprekken',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  subtitle: Text(
                    'Deze actie kan niet ongedaan worden gemaakt',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteAllChatsDialog(context, provider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T) onChanged,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: 'Selecteer...',
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                labelBuilder(item),
                style: textTheme.bodyLarge,
              ),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
      dropdownColor: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16), // M3 large shape
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
          icon: Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 32,
          ),
          title: Text(
            'Alle gesprekken verwijderen',
            style: textTheme.headlineSmall,
          ),
          content: Text(
            'Weet u zeker dat u alle gesprekken wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.',
            style: textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.clearAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alle gesprekken zijn verwijderd'),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );
  }
}
