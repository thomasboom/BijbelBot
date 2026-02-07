import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for the chat input field with send button
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isLoading;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  void _sendMessage() {
    if (widget.isLoading || !widget.isEnabled) return;
    final message = widget.controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
    }
  }

  void _insertNewline() {
    if (widget.isLoading || !widget.isEnabled) return;
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;

    if (!selection.isValid) {
      controller.text = '$text\n';
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final newText = text.replaceRange(start, end, '\n');
    final newOffset = start + 1;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(51), // 0.2 opacity
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.enter): _sendMessage,
                const SingleActivator(LogicalKeyboardKey.enter, shift: true): _insertNewline,
                const SingleActivator(LogicalKeyboardKey.enter, control: true): _insertNewline,
              },
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: 'Stel een vraag over de Bijbel...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withAlpha(153), // 0.6 opacity
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withAlpha(128), // 0.5 opacity
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withAlpha(128), // 0.5 opacity
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                enabled: !widget.isLoading && widget.isEnabled,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: (widget.isLoading || !widget.isEnabled)
                  ? colorScheme.outline.withAlpha(128) // 0.5 opacity
                  : colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: (widget.isLoading || !widget.isEnabled) ? null : _sendMessage,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: colorScheme.onPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
