import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// M3 Expressive API key dialog
///
/// Features:
/// - M3 dialog shape with extraLarge corner radius
/// - Dynamic color from theme colorScheme
/// - M3 text field styling
/// - Expressive motion for interactions
Future<void> showApiKeyDialog({
  required BuildContext context,
  required String? existingKey,
  required Future<void> Function(String) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return _ApiKeyDialog(existingKey: existingKey, onSave: onSave);
    },
  );
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog({required this.existingKey, required this.onSave});

  final String? existingKey;
  final Future<void> Function(String) onSave;

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingKey ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    await widget.onSave(_controller.text.trim());
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      icon: Icon(Icons.vpn_key_outlined, color: colorScheme.primary, size: 32),
      title: Text(localizations.setApiKey, style: textTheme.headlineSmall),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.enterApiKeyDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              obscureText: _obscure,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: localizations.ollamaApiKey,
                labelStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                helperText: localizations.storedLocallyOnly,
                helperStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _obscure
                      ? localizations.showKey
                      : localizations.hideKey,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.enterValidApiKey;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(localizations.save)),
      ],
    );
  }
}
