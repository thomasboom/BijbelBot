import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_conversation.dart';
import '../providers/bible_chat_provider.dart';

/// M3 Expressive conversation history sidebar
/// 
/// Features:
/// - M3 navigation drawer styling
/// - Dynamic color from theme colorScheme
/// - M3 shape system for list items
/// - Expressive motion for interactions
class ConversationHistorySidebar extends StatelessWidget {
  final Function(BibleChatConversation)? onConversationSelected;
  final Function()? onNewConversation;
  final String? selectedConversationId;

  const ConversationHistorySidebar({
    super.key,
    this.onConversationSelected,
    this.onNewConversation,
    this.selectedConversationId,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<BibleChatProvider>(context);
    final conversations = provider.conversationsByLastActivity.reversed.toList();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Header with title and new conversation button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Gesprekken',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // M3 Expressive FAB for new conversation
              FloatingActionButton(
                onPressed: onNewConversation,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        
        // M3 Divider
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant,
        ),
        
        // Conversation list
        Expanded(
          child: provider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                )
              : conversations.isEmpty
                  ? _buildEmptyState(colorScheme, textTheme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ConversationItem(
                          conversation: conversation,
                          isSelected: selectedConversationId == conversation.id,
                          onTap: () => onConversationSelected?.call(conversation),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// M3 Expressive empty state
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Geen gesprekken',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Begin een nieuw gesprek om hier te verschijnen',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// M3 Expressive conversation list item
class ConversationItem extends StatelessWidget {
  final BibleChatConversation conversation;
  final bool isSelected;
  final VoidCallback? onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected 
          ? colorScheme.secondaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // M3 avatar with proper shape
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_rounded,
                  size: 20,
                  color: isSelected 
                      ? colorScheme.secondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title ?? localizations.newConversation,
                      style: textTheme.titleSmall?.copyWith(
                        color: isSelected 
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(conversation.lastActivity),
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? colorScheme.onSecondaryContainer.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Vandaag ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Gisteren ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${_getWeekday(dateTime)} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getWeekday(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1: return 'Ma';
      case 2: return 'Di';
      case 3: return 'Wo';
      case 4: return 'Do';
      case 5: return 'Vr';
      case 6: return 'Za';
      case 7: return 'Zo';
      default: return '';
    }
  }
}
