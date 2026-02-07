import 'package:flutter/material.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_message.dart';
import '../models/bible_chat_conversation.dart';
import '../services/bible_bot_service.dart';
import '../services/connection_service.dart';
import '../services/logger.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../providers/bible_chat_provider.dart';
import '../widgets/api_key_dialog.dart';

/// M3 Expressive main chat interface screen
/// 
/// Features:
/// - Dynamic color from theme colorScheme
/// - M3 shape system for components
/// - Expressive motion for interactions
/// - Proper typography using M3 type scale
class BibleChatScreen extends StatefulWidget {
  /// The conversation to display/manage
  final BibleChatConversation conversation;
  
  /// Callback when the conversation is updated
  final Function(BibleChatConversation)? onConversationUpdated;
  
  /// Callback when user wants to go back
  final VoidCallback? onBackPressed;

  const BibleChatScreen({
    super.key,
    required this.conversation,
    this.onConversationUpdated,
    this.onBackPressed,
  });

  @override
  State<BibleChatScreen> createState() => _BibleChatScreenState();
}

class _BibleChatScreenState extends State<BibleChatScreen>
    with WidgetsBindingObserver {
  final BibleBotService _bibleBotService = BibleBotService.instance;
  final ConnectionService _connectionService = ConnectionService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  BibleChatProvider? _chatProvider;
  List<BibleChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isOnline = true;
  bool _providerListenerAttached = false;
  bool _needsApiKey = false;
  String? _lastApiKey;
  bool _didInitChat = false;

  // Throttling for scroll-to-bottom during streaming
  Timer? _scrollDebounceTimer;
  static const Duration _scrollDebounceDelay = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeConnectionService();
  }

  @override
  void didUpdateWidget(BibleChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if conversation changed
    if (oldWidget.conversation.id != widget.conversation.id) {
      _refreshConversation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    _attachProviderListener();
    if (!_didInitChat) {
      _didInitChat = true;
      _initializeChat();
    }
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _detachProviderListener();
    _connectionService.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectionService() async {
    try {
      await _connectionService.initialize();
      setState(() {
        _isOnline = _connectionService.isConnected;
      });

      // Listen for connectivity changes
      _connectionService.checkConnection().then((_) {
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          setState(() {
            _isOnline = _connectionService.isConnected;
            if (!_isOnline && _errorMessage == null) {
              _errorMessage = localizations.noInternetConnection;
            } else if (_isOnline &&
                _errorMessage?.contains(localizations.noInternetConnection) == true) {
              _errorMessage = null;
            }
          });
        }
      });
    } catch (e) {
      AppLogger.error('Failed to initialize connection service', e);
    }
  }

  Future<void> _retryLastAction() async {
    final localizations = AppLocalizations.of(context);
    setState(() {
      _errorMessage = null;
    });

    if (!_isOnline) {
      setState(() {
        _errorMessage = localizations.noInternetConnection;
      });
      return;
    }

    // Retry the last message if there was one
    final lastUserMessage = _messages.lastWhere(
      (message) => message.sender == MessageSender.user,
      orElse: () => _messages.isNotEmpty
          ? _messages.last
          : BibleChatMessage(
              id: '',
              content: '',
              sender: MessageSender.user,
              type: MessageType.text,
              timestamp: DateTime.now(),
            ),
    );

    if (lastUserMessage.content.isNotEmpty) {
      await _sendMessage(lastUserMessage.content);
    } else {
      // If no message to retry, just refresh the conversation
      await _refreshConversation();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshConversation();
    }
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_chatProvider == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _chatProvider!.ensureReady();
      if (!_chatProvider!.hasApiKey) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
          _needsApiKey = true;
        });
        return;
      }

      // Initialize BibleBot service
      await _bibleBotService.initialize(apiKey: _chatProvider!.apiKey!);

      // Load conversation messages
      await _loadConversationMessages();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _needsApiKey = false;
        _lastApiKey = _chatProvider!.apiKey;
      });

      // Scroll to bottom after initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      AppLogger.error('Failed to initialize Bible chat', e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        setState(() {
          _isLoading = false;
          _errorMessage = localizations.couldNotInitializeChat(e.toString());
        });
      }
    }
  }

  Future<void> _loadConversationMessages() async {
    try {
      if (_chatProvider == null) {
        AppLogger.warning('Chat provider not available');
        setState(() {
          _messages = [];
        });
        return;
      }

      await _chatProvider!.ensureReady();

      // Load messages from the provider
      _syncMessagesFromProvider();

      AppLogger.info(
        'Loaded ${_messages.length} messages for conversation ${widget.conversation.id}',
      );
    } catch (e) {
      AppLogger.error('Failed to load conversation messages', e);
      setState(() {
        _messages = [];
      });
      rethrow;
    }
  }

  Future<void> _refreshConversation() async {
    if (widget.conversation.id.isEmpty) return;

    try {
      await _loadConversationMessages();
    } catch (e) {
      AppLogger.error('Failed to refresh conversation', e);
    }
  }

  Future<void> _sendMessage(String message) async {
    final localizations = AppLocalizations.of(context);
    if (message.trim().isEmpty || _isLoading || _chatProvider == null) return;
    if (!_chatProvider!.hasApiKey) {
      setState(() {
        _errorMessage = localizations.addApiKeyFirst;
        _needsApiKey = true;
      });
      return;
    }

    BibleChatMessage? botMessage;

    try {
      // Add user message through provider
      await _chatProvider!.addMessage(
        conversationId: widget.conversation.id,
        content: message.trim(),
        sender: MessageSender.user,
        type: MessageType.question,
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      _syncMessagesFromProvider();

      // Clear input field
      _messageController.clear();

      // Scroll to bottom to show user message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      final history = _buildHistoryForAi();

      // Create placeholder bot message for streaming updates
      botMessage = await _chatProvider!.addMessage(
        conversationId: widget.conversation.id,
        content: '',
        sender: MessageSender.bot,
        type: MessageType.explanation,
      );

      // Stream response chunks
      final buffer = StringBuffer();
      await for (final chunk
          in _bibleBotService
              .askQuestionStream(
                question: message,
                history: history,
                promptSettings: _chatProvider!.promptSettings,
              )
              .timeout(const Duration(seconds: 45))) {
        buffer.write(chunk);
        await _chatProvider!.updateMessageContent(
          messageId: botMessage.id,
          content: buffer.toString(),
          persist: false,
        );
        _syncMessagesFromProvider();
        // Use debounced scroll during streaming to prevent jank
        _scrollToBottomDebounced();
      }

      final fullText = buffer.toString().trim();

      if (fullText.isEmpty) {
        // Fallback to non-streaming if stream produced nothing
        final response = await _bibleBotService
            .askQuestion(
              question: message,
              questionType: 'general_question',
              conversationId: widget.conversation.id,
              history: history,
              promptSettings: _chatProvider!.promptSettings,
            )
            .timeout(const Duration(seconds: 45));

        await _chatProvider!.updateMessageContent(
          messageId: botMessage.id,
          content: response.answer,
          bibleReferences: response.references
              .map(
                (ref) =>
                    '${ref.book} ${ref.chapter}:${ref.verse}${ref.endVerse != null ? '-${ref.endVerse}' : ''}',
              )
              .toList(),
        );
      } else {
        final references = _bibleBotService.extractBibleReferences(fullText);
        await _chatProvider!.updateMessageContent(
          messageId: botMessage.id,
          content: fullText,
          bibleReferences: references
              .map(
                (ref) =>
                    '${ref.book} ${ref.chapter}:${ref.verse}${ref.endVerse != null ? '-${ref.endVerse}' : ''}',
              )
              .toList(),
        );
      }

      setState(() {
        _isLoading = false;
      });
      _syncMessagesFromProvider();

      // Scroll to bottom to show bot response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } on TimeoutException catch (e) {
      AppLogger.error('Request timed out', e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);

        if (botMessage != null) {
          await _chatProvider!.updateMessageContent(
            messageId: botMessage.id,
            content: localizations.responseTakingLonger,
          );
        } else {
          await _chatProvider!.addMessage(
            conversationId: widget.conversation.id,
            content: localizations.responseTakingLonger,
            sender: MessageSender.bot,
            type: MessageType.text,
          );
        }

        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _syncMessagesFromProvider();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      AppLogger.error('Failed to send message', e);
      final localizations = AppLocalizations.of(context);

      // Create error message through provider
      if (botMessage != null) {
        await _chatProvider!.updateMessageContent(
          messageId: botMessage.id,
          content: localizations.errorProcessingQuestion,
        );
      } else {
        await _chatProvider!.addMessage(
          conversationId: widget.conversation.id,
          content: localizations.errorProcessingQuestion,
          sender: MessageSender.bot,
          type: MessageType.text,
        );
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _syncMessagesFromProvider();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  /// M3 Expressive scroll animation with proper easing
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250), // M3 medium duration
        curve: Curves.easeOutCubic, // M3 standard easing
      );
    }
  }

  /// Debounced scroll to bottom for use during streaming to prevent jank.
  /// Only scrolls at most once every 100ms.
  void _scrollToBottomDebounced() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(_scrollDebounceDelay, () {
      if (mounted && _scrollController.hasClients) {
        // Use jumpTo for better performance during streaming
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _startNewConversation() async {
    if (_chatProvider == null) return;
    final localizations = AppLocalizations.of(context);

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Create a new conversation
      final newConversation = await _chatProvider!.createConversation(
        title: localizations.newConversation,
      );

      // Set as active conversation
      await _chatProvider!.setActiveConversation(newConversation.id);

      // Clear current messages
      setState(() {
        _messages.clear();
        _isLoading = false;
      });

      // Update the conversation through the callback
      widget.onConversationUpdated?.call(newConversation);

      AppLogger.info('Started new conversation: ${newConversation.id}');

      // Scroll to top to show empty state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (e) {
      AppLogger.error('Failed to start new conversation', e);
      final localizations = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.couldNotStartNewConversation(e.toString());
      });
    }
  }

  Future<void> _promptForApiKey() async {
    if (_chatProvider == null) return;
    await _chatProvider!.ensureReady();

    await showApiKeyDialog(
      context: context,
      existingKey: _chatProvider!.apiKey,
      onSave: (value) async {
        await _chatProvider!.setApiKey(value);
      },
    );

    if (mounted && _chatProvider!.hasApiKey) {
      await _initializeChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final hasApiKey = _chatProvider?.hasApiKey ?? false;
    final showApiKeyRequired = _needsApiKey || !hasApiKey;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_outlined),
                onPressed: widget.onBackPressed,
              )
            : null,
        title: null,
        actions: const [],
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0, // M3: No elevation when scrolled
      ),
      body: Container(
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chat messages area
            Expanded(
              child: Container(
                child: showApiKeyRequired
                    ? _buildApiKeyRequired()
                    : (_isInitialized
                          ? _buildChatMessages()
                          : _buildLoadingView()),
              ),
              ),

            // Error message if present
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16), // M3 large shape
                ),
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.3, // Limit error container height
                ),
                child: Row(
                  children: [
                    Icon(
                      _isOnline ? Icons.error_outline : Icons.wifi_off_outlined,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    if (_isOnline) ...[
                      IconButton(
                        onPressed: _retryLastAction,
                        icon: Icon(
                          Icons.refresh_outlined,
                          color: colorScheme.onErrorContainer,
                        ),
                        tooltip: localizations.retry,
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () => setState(() => _errorMessage = null),
                      icon: Icon(
                        Icons.close_outlined,
                        color: colorScheme.onErrorContainer,
                      ),
                      tooltip: localizations.close,
                    ),
                  ],
                ),
              ),

            // Chat invoerveld
            ChatInputField(
              controller: _messageController,
              onSendMessage: _sendMessage,
              isLoading: _isLoading,
              isEnabled: hasApiKey && _isInitialized,
            ),
          ],
        ),
      ),
    );
  }

  /// M3 Expressive API key required state
  Widget _buildApiKeyRequired() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.apiKeyRequired,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.addApiKeyToUseChat,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _promptForApiKey,
                    child: Text(localizations.addApiKey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// M3 Expressive loading view
  Widget _buildLoadingView() {
    final localizations = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.initializingBibleChat,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    if (_messages.isEmpty) {
      return _buildEmptyChat();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      // Performance optimizations for smooth scrolling
      physics: const ClampingScrollPhysics(),
      cacheExtent: 200.0,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ChatMessageBubble(
              key: ValueKey(message.id),
              message: message,
              isError:
                  message.type == MessageType.text &&
                  message.content.contains('Sorry, I encountered an error'),
            ),
          ),
        );
      },
    );
  }

  /// M3 Expressive empty chat state
  Widget _buildEmptyChat() {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height - 200, // Ensure minimum height
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.startConversation,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              // Sample questions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildSampleQuestion(localizations.sampleQuestion1),
                    const SizedBox(height: 12),
                    _buildSampleQuestion(
                      localizations.sampleQuestion2,
                    ),
                    const SizedBox(height: 12),
                    _buildSampleQuestion(
                      localizations.sampleQuestion3,
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

  /// M3 Expressive sample question chip
  Widget _buildSampleQuestion(String question) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16), // M3 large shape
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _sendMessage(question),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Text(
            question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _attachProviderListener() {
    if (_chatProvider == null || _providerListenerAttached) return;
    _chatProvider!.addListener(_onProviderUpdated);
    _providerListenerAttached = true;
  }

  void _detachProviderListener() {
    if (_chatProvider == null || !_providerListenerAttached) return;
    _chatProvider!.removeListener(_onProviderUpdated);
    _providerListenerAttached = false;
  }

  void _onProviderUpdated() {
    if (!mounted || _chatProvider == null) return;
    if (_chatProvider!.isLoading) return;

    if (!_isLoading &&
        _chatProvider!.hasApiKey &&
        _chatProvider!.apiKey != _lastApiKey) {
      _initializeChat();
      return;
    }

    _syncMessagesFromProvider();
  }

  void _syncMessagesFromProvider() {
    if (!mounted || _chatProvider == null) return;
    final messages = _chatProvider!.getConversationMessages(
      widget.conversation.id,
    );
    setState(() {
      _messages = messages;
    });
  }

  List<Map<String, String>> _buildHistoryForAi() {
    final localizations = AppLocalizations.of(context);
    final history = <Map<String, String>>[];
    for (final message in _messages) {
      if (message.content.trim().isEmpty) continue;
      if (message.sender == MessageSender.bot &&
          (message.content.contains(localizations.errorProcessingQuestion) ||
              message.content.contains('Sorry, I encountered an error'))) {
        continue;
      }

      history.add({
        'role': message.sender == MessageSender.user ? 'user' : 'assistant',
        'content': message.content,
      });
    }
    return history;
  }
}
