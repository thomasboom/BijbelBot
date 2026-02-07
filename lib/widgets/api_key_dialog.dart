import 'package:flutter/material.dart';

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
      return _ApiKeyDialog(
        existingKey: existingKey,
        onSave: onSave,
      );
    },
  );
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog({
    required this.existingKey,
    required this.onSave,
  });

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
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      icon: Icon(
        Icons.vpn_key_outlined,
        color: colorScheme.primary,
        size: 32,
      ),
      title: Text(
        'API key instellen',
        style: textTheme.headlineSmall,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voer je Ollama API key in om de chat te gebruiken. De key wordt alleen lokaal opgeslagen op dit apparaat.',
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
                labelText: 'Ollama API key',
                labelStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                helperText: 'Wordt alleen lokaal opgeslagen',
                helperStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _obscure ? 'Toon key' : 'Verberg key',
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vul een geldige API key in.';
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
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
