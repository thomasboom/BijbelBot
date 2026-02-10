import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../l10n/app_localizations.dart';

/// M3 Expressive chat input field widget
///
/// Features:
/// - M3 shape system with extraLarge corner radius
/// - Dynamic color from theme colorScheme
/// - Expressive motion for interactions
/// - Proper typography using M3 type scale
/// - Speech to text functionality
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

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _sendButtonController,
        curve: Curves.easeOutCubic,
      ),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          widget.controller.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

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
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
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
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_speechEnabled)
                IconButton(
                  onPressed: widget.isLoading ? null : _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? colorScheme.primary
                        : widget.isLoading || !widget.isEnabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                  tooltip: localizations.microphone,
                ),
              Expanded(
                child: CallbackShortcuts(
                  bindings: <ShortcutActivator, VoidCallback>{
                    const SingleActivator(LogicalKeyboardKey.enter):
                        _sendMessage,
                    const SingleActivator(
                      LogicalKeyboardKey.enter,
                      shift: true,
                    ): _insertNewline,
                    const SingleActivator(
                      LogicalKeyboardKey.enter,
                      control: true,
                    ): _insertNewline,
                  },
                  child: TextField(
                    controller: widget.controller,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: localizations.askQuestionAboutBible,
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    maxLines: null,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !widget.isLoading && widget.isEnabled,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ScaleTransition(
                scale: _sendButtonScale,
                child: FloatingActionButton(
                  onPressed: (widget.isLoading || !widget.isEnabled)
                      ? null
                      : _sendMessage,
                  backgroundColor: (widget.isLoading || !widget.isEnabled)
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primaryContainer,
                  foregroundColor: (widget.isLoading || !widget.isEnabled)
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onPrimaryContainer,
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  shape: const CircleBorder(),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Text(
              localizations.aiDisclaimer,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
