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
/// - Search functionality to filter conversations
class ConversationHistorySidebar extends StatefulWidget {
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
  State<ConversationHistorySidebar> createState() => _ConversationHistorySidebarState();
}

class _ConversationHistorySidebarState extends State<ConversationHistorySidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BibleChatConversation> _filterConversations(List<BibleChatConversation> conversations) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }
    final query = _searchQuery.toLowerCase();
    return conversations.where((conversation) {
      final title = (conversation.title ?? '').toLowerCase();
      return title.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final provider = Provider.of<BibleChatProvider>(context);
    final allConversations = provider.conversationsByLastActivity.reversed.toList();
    final filteredConversations = _filterConversations(allConversations);
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
                  localizations.conversations,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // M3 Expressive FAB for new conversation
              FloatingActionButton(
                onPressed: widget.onNewConversation,
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
        
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: localizations.searchConversations,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
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
              : filteredConversations.isEmpty
                  ? _buildEmptyState(colorScheme, textTheme, _searchQuery.isNotEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        return ConversationItem(
                          conversation: conversation,
                          isSelected: widget.selectedConversationId == conversation.id,
                          onTap: () => widget.onConversationSelected?.call(conversation),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// M3 Expressive empty state
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme, bool isSearchResult) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchResult ? localizations.noResults : localizations.noConversations,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchResult ? localizations.tryDifferentSearchTerm : localizations.startNewConversationToAppear,
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
    final localizations = AppLocalizations.of(context);
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
                      _formatDate(conversation.lastActivity, localizations),
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

  String _formatDate(DateTime dateTime, AppLocalizations localizations) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${localizations.today} ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return '${localizations.yesterday} ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${_getWeekday(dateTime, localizations)} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getWeekday(DateTime dateTime, AppLocalizations localizations) {
    switch (dateTime.weekday) {
      case 1: return localizations.monday;
      case 2: return localizations.tuesday;
      case 3: return localizations.wednesday;
      case 4: return localizations.thursday;
      case 5: return localizations.friday;
      case 6: return localizations.saturday;
      case 7: return localizations.sunday;
      default: return '';
    }
  }
}
