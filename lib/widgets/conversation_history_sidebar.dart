import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_conversation.dart';
import '../providers/bible_chat_provider.dart';

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

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with title and new conversation button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Gesprekken',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onNewConversation,
                  icon: const Icon(Icons.add),
                  tooltip: localizations.newConversation,
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          
          // Conversation list
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : provider.conversations.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Geen gesprekken',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Begin een nieuw gesprek om hier te verschijnen',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: provider.conversations.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final conversation = provider.conversations.reversed.toList()[index];
                          return ConversationItem(
                            conversation: conversation,
                            isSelected: selectedConversationId == conversation.id,
                            onTap: () => onConversationSelected?.call(conversation),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        conversation.title ?? localizations.newConversation,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        _formatDate(conversation.lastActivity),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: isSelected 
            ? colorScheme.primary 
            : colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected 
            ? colorScheme.onPrimary 
            : colorScheme.primary,
        child: Icon(
          Icons.chat_rounded,
          size: 18,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer,
      onTap: onTap,
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