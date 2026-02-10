import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'theme/app_theme.dart';
import 'models/bible_chat_conversation.dart';
import 'providers/bible_chat_provider.dart';
import 'screens/bible_chat_screen.dart';
import 'widgets/common/conversation_history_sidebar.dart';
import 'widgets/common/settings_menu.dart';
import 'l10n/app_localizations.dart';

/// Main application widget for BijbelBot
class BijbelBotApp extends StatelessWidget {
  const BijbelBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BibleChatProvider(),
      child: Consumer<BibleChatProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildLightTheme(),
            darkTheme: AppTheme.buildDarkTheme(),
            themeMode: provider.themeMode,
            locale: provider.language == 'system'
                ? null
                : Locale(provider.language),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en'), const Locale('nl')],
            home: const BijbelBotHomePage(),
          );
        },
      ),
    );
  }
}

/// Home page widget for BijbelBot
class BijbelBotHomePage extends StatefulWidget {
  const BijbelBotHomePage({super.key});

  @override
  State<BijbelBotHomePage> createState() => _BijbelBotHomePageState();
}

class _BijbelBotHomePageState extends State<BijbelBotHomePage> {
  BibleChatConversation? _currentConversation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  Future<void> _initializeConversation() async {
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    await chatProvider.ensureReady();

    if (chatProvider.activeConversation == null) {
      try {
        final conversation = await chatProvider.createConversation(
          title: localizations.newBibleChat,
        );
        setState(() {
          _currentConversation = conversation;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${localizations.errorInitializing} $e')),
          );
        }
      }
    } else {
      setState(() {
        _currentConversation = chatProvider.activeConversation;
      });
    }
  }

  void _onConversationUpdated(BibleChatConversation conversation) {
    setState(() {
      _currentConversation = conversation;
    });
  }

  void _onConversationSelected(BibleChatConversation conversation) {
    setState(() {
      _currentConversation = conversation;
    });
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    chatProvider.setActiveConversation(conversation.id);
  }

  Future<void> _createNewConversation() async {
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    try {
      final conversation = await chatProvider.createConversation(
        title: localizations.newConversation,
      );
      setState(() {
        _currentConversation = conversation;
      });
      chatProvider.setActiveConversation(conversation.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorCreatingConversation} $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bibleBot),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: localizations.openConversations,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _createNewConversation,
            icon: const Icon(Icons.add_comment),
            tooltip: localizations.newConversation,
          ),
          const SettingsMenu(),
        ],
      ),
      drawer: Drawer(
        width: AppConfig.defaultDrawerWidth,
        child: ConversationHistorySidebar(
          selectedConversationId: _currentConversation?.id,
          onConversationSelected: (conversation) {
            _onConversationSelected(conversation);
            Navigator.of(context).pop();
          },
          onNewConversation: () {
            _createNewConversation();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _currentConversation == null
          ? const Center(child: CircularProgressIndicator())
          : BibleChatScreen(
              conversation: _currentConversation!,
              onConversationUpdated: _onConversationUpdated,
            ),
    );
  }
}
