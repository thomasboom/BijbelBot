import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: colorScheme.surface,
      title: Text('API key instellen', style: textTheme.titleLarge),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          obscureText: _obscure,
          style: textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Ollama API key',
            labelStyle: textTheme.bodyLarge,
            helperText: 'Wordt alleen lokaal opgeslagen op dit apparaat.',
            helperStyle: textTheme.bodySmall,
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
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vul een geldige API key in.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuleren', style: textTheme.labelLarge),
        ),
        TextButton(
          onPressed: _save,
          child: Text('Opslaan', style: textTheme.labelLarge),
        ),
      ],
    );
  }
}
