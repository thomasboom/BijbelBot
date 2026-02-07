import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bible_chat_message.dart';
import '../models/bible_chat_conversation.dart';
import '../services/logger.dart';
import '../widgets/biblical_reference_dialog.dart';

/// Provider for managing Bible chat conversations and messages
class BibleChatProvider extends ChangeNotifier {
  static const String _conversationsKey = 'bible_chat_conversations';
  static const String _messagesKey = 'bible_chat_messages';
  static const String _activeConversationKey = 'bible_chat_active_conversation';
  static const Duration _emptyConversationGracePeriod = Duration(minutes: 10);

  SharedPreferences? _prefs;
  late final Future<void> _ready;

  // In-memory storage for quick access
  final Map<String, BibleChatConversation> _conversations = {};
  final Map<String, BibleChatMessage> _messages = {};
  String? _activeConversationId;

  bool _isLoading = true;
  String? _error;
  Future<void> _saveChain = Future.value();

  BibleChatProvider() {
    AppLogger.info('BibleChatProvider initializing...');
    _ready = _loadChatData();
  }

  /// Whether chat data is currently being loaded
  bool get isLoading => _isLoading;

  /// Any error that occurred while loading or saving chat data
  String? get error => _error;

  /// List of all conversations
  List<BibleChatConversation> get conversations => _conversations.values.toList();

  /// Conversations sorted by last activity (oldest to newest).
  List<BibleChatConversation> get conversationsByLastActivity {
    final items = _conversations.values.toList();
    items.sort((a, b) => a.lastActivity.compareTo(b.lastActivity));
    return items;
  }

  /// List of active conversations only
  List<BibleChatConversation> get activeConversations =>
      _conversations.values.where((conv) => conv.isActive).toList();

  /// The currently active conversation
  BibleChatConversation? get activeConversation =>
      _activeConversationId != null ? _conversations[_activeConversationId] : null;

  /// Waits until chat data is fully loaded and storage is ready.
  Future<void> ensureReady() async {
    await _ensureReady();
  }

  /// Gets a conversation by ID
  BibleChatConversation? getConversation(String conversationId) =>
      _conversations[conversationId];

  /// Gets messages for a specific conversation
  List<BibleChatMessage> getConversationMessages(String conversationId) {
    final conversation = _conversations[conversationId];
    if (conversation == null) return [];

    return conversation.messageIds
        .map((messageId) => _messages[messageId])
        .where((message) => message != null)
        .cast<BibleChatMessage>()
        .toList();
  }

  /// Gets a message by ID
  BibleChatMessage? getMessage(String messageId) => _messages[messageId];

  /// Creates a new conversation
  Future<BibleChatConversation> createConversation({
    String? title,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _ensureReady();
      final conversation = BibleChatConversation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        messageIds: [],
        title: title,
        userContext: userContext,
        metadata: metadata,
      );

      await _saveConversation(conversation);
      _setActiveIfMissing(conversation.id);

      AppLogger.info('Created new conversation: ${conversation.id}');

      notifyListeners();
      return conversation;
    } catch (e) {
      _error = 'Failed to create conversation: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Cleans up empty conversations (those with no messages)
  Future<void> cleanupEmptyConversations({Duration? minimumAge, bool skipReadyCheck = false}) async {
    try {
      final now = DateTime.now();
      final grace = minimumAge ?? _emptyConversationGracePeriod;
      final emptyConversations = _conversations.values
          .where((conversation) => conversation.messageIds.isEmpty)
          .toList();

      for (final conversation in emptyConversations) {
        // Don't delete the active conversation even if it's empty
        if (conversation.id == _activeConversationId) {
          continue;
        }

        // Skip very recent conversations to prevent accidental deletion
        if (now.difference(conversation.startTime) < grace) {
          continue;
        }

        await deleteConversation(conversation.id, skipReadyCheck: skipReadyCheck);
      }

      AppLogger.info('Cleaned up ${emptyConversations.length} empty conversations');
    } catch (e) {
      AppLogger.error('Failed to clean up empty conversations: $e');
    }
  }

  /// Adds a message to a conversation
  Future<BibleChatMessage> addMessage({
    required String conversationId,
    required String content,
    required MessageSender sender,
    required MessageType type,
    List<String>? bibleReferences,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _ensureReady();
      final message = BibleChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        sender: sender,
        type: type,
        bibleReferences: bibleReferences,
        metadata: metadata,
      );

      // Update conversation with new message
      var updatedConversation = _conversations[conversationId];
      if (updatedConversation != null) {
        updatedConversation = updatedConversation.withNewMessage(message.id);
        
        // Generate a title every time the AI responds, based on the latest user message
        if (sender == MessageSender.bot) {
          final latestUserMessage = await _getLatestUserMessageInConversation(conversationId);
          if (latestUserMessage != null) {
            final generatedTitle = await _generateTitleFromMessage(latestUserMessage);
            updatedConversation = updatedConversation.copyWith(title: generatedTitle);
          }
        }
        
      } else {
        // Recover from missing conversation by creating a placeholder
        updatedConversation = BibleChatConversation(
          id: conversationId,
          startTime: DateTime.now(),
          messageIds: [message.id],
          title: null,
        );
      }

      _messages[message.id] = message;
      _conversations[updatedConversation.id] = updatedConversation;

      await _saveAllMessages();
      await _saveAllConversations();

      // Clean up empty conversations after adding a message
      await cleanupEmptyConversations();

      AppLogger.info('Added message ${message.id} to conversation $conversationId');
      notifyListeners();
      return message;
    } catch (e) {
      _error = 'Failed to add message: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Gets the first user message in a conversation
  Future<BibleChatMessage?> _getFirstUserMessageInConversation(String conversationId) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return null;

    // Find the first user message in the conversation
    for (final messageId in conversation.messageIds) {
      final message = _messages[messageId];
      if (message != null && message.sender == MessageSender.user) {
        return message;
      }
    }
    return null;
  }

  /// Gets the latest user message in a conversation
  Future<BibleChatMessage?> _getLatestUserMessageInConversation(String conversationId) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return null;

    for (final messageId in conversation.messageIds.reversed) {
      final message = _messages[messageId];
      if (message != null && message.sender == MessageSender.user) {
        return message;
      }
    }
    return null;
  }

  /// Generates a title from the first user message
  Future<String> _generateTitleFromMessage(BibleChatMessage message) async {
    // Create a title based on the first 60 characters of the user's message
    String title = message.content.trim();
    if (title.length > 60) {
      title = title.substring(0, 60);
      // Find the last space to avoid cutting words
      final lastSpaceIndex = title.lastIndexOf(' ');
      if (lastSpaceIndex > 0) {
        title = title.substring(0, lastSpaceIndex);
      }
      title += '...';
    }
    
    // Capitalize the first letter
    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }
    
    return title;
  }

  bool _isDefaultTitle(String? title) {
    if (title == null || title.trim().isEmpty) return true;
    final normalized = title.trim().toLowerCase();
    const defaults = {
      'new bible chat',
      'nieuwe bijbel chat',
      'new conversation',
      'nieuwe conversatie',
    };
    return defaults.contains(normalized) || normalized.startsWith('nieuwe conversatie');
  }

  /// Updates an existing conversation
  Future<void> updateConversation(BibleChatConversation conversation) async {
    try {
      await _ensureReady();
      await _saveConversation(conversation);
      AppLogger.info('Updated conversation: ${conversation.id}');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update conversation: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a conversation and all its messages
  Future<void> deleteConversation(String conversationId, {bool skipReadyCheck = false}) async {
    try {
      if (!skipReadyCheck) {
        await _ensureReady();
      }
      final conversation = _conversations[conversationId];
      if (conversation == null) return;

      // Remove all messages in this conversation
      for (final messageId in conversation.messageIds) {
        _messages.remove(messageId);
      }

      // Remove conversation
      _conversations.remove(conversationId);

      // Clear active conversation if it was deleted
      if (_activeConversationId == conversationId) {
        _activeConversationId = null;
        await _prefs?.remove(_activeConversationKey);
      }

      await _saveAllConversations();
      await _saveAllMessages();

      AppLogger.info('Deleted conversation: $conversationId');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Sets the active conversation
  Future<void> setActiveConversation(String? conversationId) async {
    try {
      await _ensureReady();
      _activeConversationId = conversationId;
      if (conversationId != null) {
        await _prefs?.setString(_activeConversationKey, conversationId);
      } else {
        await _prefs?.remove(_activeConversationKey);
      }

      AppLogger.info('Set active conversation: $conversationId');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set active conversation: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Marks a message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _ensureReady();
      final message = _messages[messageId];
      if (message != null && !message.isRead) {
        final updatedMessage = message.copyWith(isRead: true);
        await _saveMessage(updatedMessage);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Failed to mark message as read: $messageId', e);
      // Don't throw here as this is not critical
    }
  }

  /// Updates message content (and optional references) for streaming UI updates
  Future<void> updateMessageContent({
    required String messageId,
    required String content,
    List<String>? bibleReferences,
    bool persist = true,
  }) async {
    try {
      await _ensureReady();
      final message = _messages[messageId];
      if (message == null) return;

      final updatedMessage = message.copyWith(
        content: content,
        bibleReferences: bibleReferences ?? message.bibleReferences,
      );

      _messages[messageId] = updatedMessage;

      if (persist) {
        await _saveAllMessages();
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to update message content: $messageId', e);
    }
  }

  /// Gets conversation statistics
  Map<String, dynamic> getConversationStats() {
    final totalConversations = _conversations.length;
    final activeConversations = _conversations.values.where((c) => c.isActive).length;
    final totalMessages = _messages.length;

    return {
      'totalConversations': totalConversations,
      'activeConversations': activeConversations,
      'totalMessages': totalMessages,
    };
  }

  /// Exports all chat data for backup
  Map<String, dynamic> exportChatData() {
    return {
      'conversations': _conversations.map((key, value) => MapEntry(key, value.toJson())),
      'messages': _messages.map((key, value) => MapEntry(key, value.toJson())),
      'activeConversationId': _activeConversationId,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Imports chat data from backup
  Future<void> importChatData(Map<String, dynamic> data) async {
    try {
      await _ensureReady();
      _conversations.clear();
      _messages.clear();

      // Import conversations
      final conversationsData = data['conversations'] as Map<String, dynamic>? ?? {};
      for (final entry in conversationsData.entries) {
        final conversation = BibleChatConversation.fromJson(entry.value as Map<String, dynamic>);
        _conversations[entry.key] = conversation;
      }

      // Import messages
      final messagesData = data['messages'] as Map<String, dynamic>? ?? {};
      for (final entry in messagesData.entries) {
        final message = BibleChatMessage.fromJson(entry.value as Map<String, dynamic>);
        _messages[entry.key] = message;
      }

      // Set active conversation
      _activeConversationId = data['activeConversationId']?.toString();

      await _saveAllConversations();
      await _saveAllMessages();
      if (_activeConversationId != null) {
        await _prefs?.setString(_activeConversationKey, _activeConversationId!);
      }

      AppLogger.info('Imported chat data: ${_conversations.length} conversations, ${_messages.length} messages');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to import chat data: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Clears all chat data
  Future<void> clearAllData() async {
    try {
      await _ensureReady();
      _conversations.clear();
      _messages.clear();
      _activeConversationId = null;

      await _prefs?.remove(_conversationsKey);
      await _prefs?.remove(_messagesKey);
      await _prefs?.remove(_activeConversationKey);

      AppLogger.info('Cleared all chat data');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear chat data: ${e.toString()}';
      AppLogger.error(_error!, e);
      notifyListeners();
      rethrow;
    }
  }

  /// Loads all chat data from persistent storage
  Future<void> _loadChatData() async {
    try {
      AppLogger.info('Loading chat data from persistent storage...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('SharedPreferences instance obtained');

      // Load conversations
      await _loadConversations();

      // Load messages
      await _loadMessages();

      // Load active conversation
      _activeConversationId = _prefs?.getString(_activeConversationKey);

      // If active conversation is missing, select the most recent one
      if (_activeConversationId != null && !_conversations.containsKey(_activeConversationId)) {
        _activeConversationId = null;
      }

      if (_activeConversationId == null && _conversations.isNotEmpty) {
        final mostRecent = _conversations.values.reduce((a, b) =>
            a.lastActivity.isAfter(b.lastActivity) ? a : b);
        _activeConversationId = mostRecent.id;
        await _prefs?.setString(_activeConversationKey, mostRecent.id);
      }

      _reconcileConversations();
      // Clean up empty conversations after loading
      await cleanupEmptyConversations(skipReadyCheck: true);

      AppLogger.info('Chat data loaded: ${_conversations.length} conversations, ${_messages.length} messages');
    } catch (e) {
      _error = 'Failed to load chat data: ${e.toString()}';
      AppLogger.error(_error!, e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads conversations from storage
  Future<void> _loadConversations() async {
    try {
      final conversationsJson = _prefs?.getString(_conversationsKey);
      if (conversationsJson != null && conversationsJson.isNotEmpty) {
        final conversationsData = json.decode(conversationsJson) as Map<String, dynamic>;

        _conversations.clear();
        for (final entry in conversationsData.entries) {
          final conversation = BibleChatConversation.fromJson(entry.value as Map<String, dynamic>);
          _conversations[entry.key] = conversation;
        }

        AppLogger.info('Loaded ${_conversations.length} conversations');
      }
    } catch (e) {
      AppLogger.error('Failed to load conversations: $e');
      _conversations.clear();
    }
  }

  /// Loads messages from storage
  Future<void> _loadMessages() async {
    try {
      final messagesJson = _prefs?.getString(_messagesKey);
      if (messagesJson != null && messagesJson.isNotEmpty) {
        final messagesData = json.decode(messagesJson) as Map<String, dynamic>;

        _messages.clear();
        for (final entry in messagesData.entries) {
          final message = BibleChatMessage.fromJson(entry.value as Map<String, dynamic>);
          _messages[entry.key] = message;
        }

        AppLogger.info('Loaded ${_messages.length} messages');
      }
    } catch (e) {
      AppLogger.error('Failed to load messages: $e');
      _messages.clear();
    }
  }

  /// Saves a conversation to storage
  Future<void> _saveConversation(BibleChatConversation conversation) async {
    _conversations[conversation.id] = conversation;
    await _saveAllConversations();
  }

  /// Saves all conversations to storage
  Future<void> _saveAllConversations() async {
    await _withSaveLock(() async {
      try {
        final conversationsData = _conversations.map((key, value) => MapEntry(key, value.toJson()));
        final jsonString = json.encode(conversationsData);
        await _prefs?.setString(_conversationsKey, jsonString);
      } catch (e) {
        AppLogger.error('Failed to save conversations: $e');
        throw Exception('Failed to save conversations');
      }
    });
  }

  /// Saves a message to storage
  Future<void> _saveMessage(BibleChatMessage message) async {
    _messages[message.id] = message;
    await _saveAllMessages();
  }

  /// Saves all messages to storage
  Future<void> _saveAllMessages() async {
    await _withSaveLock(() async {
      try {
        final messagesData = _messages.map((key, value) => MapEntry(key, value.toJson()));
        final jsonString = json.encode(messagesData);
        await _prefs?.setString(_messagesKey, jsonString);
      } catch (e) {
        AppLogger.error('Failed to save messages: $e');
        throw Exception('Failed to save messages');
      }
    });
  }

  Future<void> _withSaveLock(Future<void> Function() action) {
    final completer = Completer<void>();
    _saveChain = _saveChain.catchError((_) {}).then((_) async {
      try {
        await action();
        completer.complete();
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _ensureReady() async {
    await _ready;
    if (_prefs == null) {
      throw Exception('Chat storage not initialized');
    }
  }

  void _setActiveIfMissing(String conversationId) {
    if (_activeConversationId == null) {
      _activeConversationId = conversationId;
      _prefs?.setString(_activeConversationKey, conversationId);
    }
  }

  void _reconcileConversations() {
    for (final entry in _conversations.entries) {
      final conversation = entry.value;
      final filteredMessageIds = conversation.messageIds
          .where((id) => _messages.containsKey(id))
          .toList();
      if (filteredMessageIds.length != conversation.messageIds.length) {
        _conversations[conversation.id] = conversation.copyWith(
          messageIds: filteredMessageIds,
        );
      }
    }
  }

  /// Shows the biblical reference dialog for a given reference
  /// This method requires a BuildContext to show the dialog
  void showBiblicalReference(BuildContext context, String reference) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BiblicalReferenceDialog(reference: reference);
        },
      );
      AppLogger.info('Showing biblical reference dialog for: $reference');
    } catch (e) {
      AppLogger.error('Failed to show biblical reference dialog: $e');
      // Could show a snackbar or toast here to inform the user
    }
  }
}
