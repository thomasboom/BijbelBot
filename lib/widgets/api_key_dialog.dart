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
    return AlertDialog(
      title: const Text('API key instellen'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Ollama API key',
            helperText: 'Wordt alleen lokaal opgeslagen op dit apparaat.',
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
          child: const Text('Annuleren'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
