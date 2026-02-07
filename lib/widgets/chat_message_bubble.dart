import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_message.dart';
import '../providers/bible_chat_provider.dart';

/// Widget for displaying a chat message bubble
/// 
/// Uses AutomaticKeepAlive to maintain state during scrolling and prevent
/// unnecessary rebuilds when streaming content updates.
class ChatMessageBubble extends StatefulWidget {
  final BibleChatMessage message;
  final bool isError;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BibleChatMessage get message => widget.message;
  bool get isError => widget.isError;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final localizations = AppLocalizations.of(context)!;
    final isUser = message.sender == MessageSender.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          _buildAvatar(isUser, colorScheme),
          const SizedBox(width: 12),
        ],
        if (isUser)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMessageBubble(isUser, colorScheme, textTheme),
              const SizedBox(height: 4),
              _buildTimestamp(colorScheme, textTheme),
            ],
          )
        else
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBotLabel(colorScheme, localizations, textTheme),
                const SizedBox(height: 4),
                _buildMessageBubble(isUser, colorScheme, textTheme),
                const SizedBox(height: 4),
                _buildTimestamp(colorScheme, textTheme),
              ],
            ),
          ),
        if (isUser) ...[
          const SizedBox(width: 12),
          _buildAvatar(isUser, colorScheme),
        ],
      ],
    );
  }

  Widget _buildAvatar(bool isUser, ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isError
            ? LinearGradient(
                colors: [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withAlpha((0.8 * 255).round()),
                ],
              )
            : (isUser
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withAlpha((0.8 * 255).round()),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      colorScheme.secondaryContainer,
                      colorScheme.secondaryContainer.withAlpha((0.8 * 255).round()),
                    ],
                  )),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isError ? Icons.error : (isUser ? Icons.person : Icons.smart_toy),
        color: isError
            ? colorScheme.onErrorContainer
            : (isUser ? colorScheme.onPrimary : colorScheme.onSecondaryContainer),
        size: 20,
      ),
    );
  }

  Widget _buildBotLabel(ColorScheme colorScheme, AppLocalizations localizations, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer.withAlpha((0.7 * 255).round())
            : colorScheme.primaryContainer.withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isError ? localizations.error : localizations.appName,
        style: textTheme.labelSmall?.copyWith(
          color: isError
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, ColorScheme colorScheme, TextTheme textTheme) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError
                ? colorScheme.errorContainer
                : (isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            border: isError
                ? Border.all(
                    color: colorScheme.error.withAlpha((0.5 * 255).round()),
                    width: 1,
                  )
                : null,
            boxShadow: isError
                ? [
                    BoxShadow(
                      color: colorScheme.error.withAlpha((0.1 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.08 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sorry, er is een fout opgetreden bij het verwerken van uw vraag. Probeer opnieuw.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildMessageContent(isUser, colorScheme, textTheme),
              ],
              if (message.bibleReferences != null && message.bibleReferences!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildBibleReferences(colorScheme, context, textTheme),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBibleReferences(ColorScheme colorScheme, BuildContext context, TextTheme textTheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.bibleReferences!.map((reference) {
        return InkWell(
          onTap: () {
            // Get the provider from context and show the biblical reference dialog
            final provider = Provider.of<BibleChatProvider>(context, listen: false);
            provider.showBiblicalReference(context, reference);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withAlpha((0.3 * 255).round()),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  reference,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageContent(bool isUser, ColorScheme colorScheme, TextTheme textTheme) {
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    if (isUser) {
      return _buildMarkdownContent(message.content, textColor, colorScheme, textTheme);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildMarkdownContent(message.content, textColor, colorScheme, textTheme),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(String content, Color textColor, ColorScheme colorScheme, TextTheme textTheme) {
    try {
      return MarkdownBody(
        data: content,
        styleSheet: _getMarkdownStyleSheet(textColor, colorScheme, textTheme),
        selectable: true,
        softLineBreak: true,
      );
    } catch (e) {
      // Fallback to plain text if markdown parsing fails
      return Text(
        content,
        style: textTheme.bodyLarge?.copyWith(
          color: textColor,
          height: 1.4,
        ),
      );
    }
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(Color textColor, ColorScheme colorScheme, TextTheme textTheme) {
    return MarkdownStyleSheet(
      p: textTheme.bodyLarge?.copyWith(
        color: textColor,
        height: 1.4,
      ),
      h1: textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      strong: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      em: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      code: textTheme.bodyMedium?.copyWith(
        color: textColor,
        backgroundColor: colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
        fontFamily: 'monospace',
      ),
      blockquote: textTheme.bodyLarge?.copyWith(
        color: textColor.withAlpha((0.8 * 255).round()),
        height: 1.4,
      ),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
        border: Border(
          left: BorderSide(
            color: colorScheme.outline.withAlpha((0.5 * 255).round()),
            width: 4,
          ),
        ),
      ),
      listBullet: textTheme.bodyLarge?.copyWith(
        color: textColor,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(ColorScheme colorScheme, TextTheme textTheme) {
    final timestamp = DateFormat('HH:mm').format(message.timestamp);

    return Text(
      timestamp,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
      ),
    );
  }
}