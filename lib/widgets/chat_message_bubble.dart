import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_message.dart';
import '../providers/bible_chat_provider.dart';

/// M3 Expressive chat message bubble widget
///
/// Features:
/// - Dynamic color from theme colorScheme
/// - M3 shape system with appropriate corner radii
/// - Expressive motion for interactions
/// - Proper typography using M3 type scale
class ChatMessageBubble extends StatefulWidget {
  final BibleChatMessage message;
  final bool isError;
  final VoidCallback? onEdit;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isError = false,
    this.onEdit,
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
    super.build(context);
    final localizations = AppLocalizations.of(context);
    final isUser = message.sender == MessageSender.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
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
              _buildMessageBubble(
                isUser,
                colorScheme,
                textTheme,
                localizations,
              ),
              const SizedBox(height: 4),
              _buildUserActions(colorScheme, textTheme, localizations),
            ],
          )
        else
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBotLabel(colorScheme, localizations, textTheme),
                const SizedBox(height: 4),
                _buildMessageBubble(
                  isUser,
                  colorScheme,
                  textTheme,
                  localizations,
                ),
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

  /// M3 Expressive avatar with proper shape and color
  Widget _buildAvatar(bool isUser, ColorScheme colorScheme) {
    final backgroundColor = isError
        ? colorScheme.errorContainer
        : (isUser
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer);

    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : (isUser
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer);

    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 0,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          isError
              ? Icons.error_outline
              : (isUser ? Icons.person_outline : Icons.smart_toy_outlined),
          color: foregroundColor,
          size: 22,
        ),
      ),
    );
  }

  /// M3 Expressive bot label chip
  Widget _buildBotLabel(
    ColorScheme colorScheme,
    AppLocalizations localizations,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer.withValues(alpha: 0.7)
            : colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8), // small shape
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

  /// M3 Expressive message bubble with shape system
  Widget _buildMessageBubble(
    bool isUser,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations localizations,
  ) {
    return Builder(
      builder: (BuildContext context) {
        final backgroundColor = isError
            ? colorScheme.errorContainer
            : (isUser
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest);

        final foregroundColor = isError
            ? colorScheme.onErrorContainer
            : (isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface);

        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            // M3 shape system: large corner radius with asymmetric corners for chat bubbles
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft: isUser
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isUser
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
            // Subtle border for error state
            border: isError
                ? Border.all(
                    color: colorScheme.error.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, size: 18, color: foregroundColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.errorProcessingQuestion,
                        style: textTheme.bodyLarge?.copyWith(
                          color: foregroundColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildMessageContent(isUser, colorScheme, textTheme),
              ],
              if (message.bibleReferences != null &&
                  message.bibleReferences!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildBibleReferences(colorScheme, context, textTheme),
              ],
            ],
          ),
        );
      },
    );
  }

  /// M3 Expressive bible reference chips
  Widget _buildBibleReferences(
    ColorScheme colorScheme,
    BuildContext context,
    TextTheme textTheme,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.bibleReferences!.map((reference) {
        return Material(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12), // medium shape
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              final provider = Provider.of<BibleChatProvider>(
                context,
                listen: false,
              );
              provider.showBiblicalReference(context, reference);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    reference,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageContent(
    bool isUser,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final textColor = isUser
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    if (isUser) {
      return _buildMarkdownContent(
        message.content,
        textColor,
        colorScheme,
        textTheme,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildMarkdownContent(
            message.content,
            textColor,
            colorScheme,
            textTheme,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(
    String content,
    Color textColor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    try {
      return MarkdownBody(
        data: content,
        styleSheet: _getMarkdownStyleSheet(textColor, colorScheme, textTheme),
        selectable: true,
        softLineBreak: true,
      );
    } catch (e) {
      return Text(
        content,
        style: textTheme.bodyLarge?.copyWith(color: textColor, height: 1.5),
      );
    }
  }

  /// M3 Expressive markdown styling
  MarkdownStyleSheet _getMarkdownStyleSheet(
    Color textColor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return MarkdownStyleSheet(
      p: textTheme.bodyLarge?.copyWith(color: textColor, height: 1.5),
      h1: textTheme.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      h2: textTheme.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.29,
      ),
      h3: textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.33,
      ),
      strong: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      em: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      code: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface,
        backgroundColor: colorScheme.surfaceContainerHighest,
        fontFamily: 'monospace',
      ),
      blockquote: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 4),
        ),
      ),
      listBullet: textTheme.bodyLarge?.copyWith(color: textColor),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
    );
  }

  /// M3 Expressive timestamp with proper typography
  Widget _buildTimestamp(ColorScheme colorScheme, TextTheme textTheme) {
    final timestamp = DateFormat('HH:mm').format(message.timestamp);

    return Text(
      timestamp,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// M3 Expressive user actions (edit button) for user messages
  Widget _buildUserActions(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations localizations,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimestamp(colorScheme, textTheme),
        if (widget.onEdit != null) ...[
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onEdit,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      localizations.edit,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
