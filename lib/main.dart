import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/bible_chat_conversation.dart';
import 'providers/bible_chat_provider.dart';
import 'screens/bible_chat_screen.dart';
import 'widgets/conversation_history_sidebar.dart';
import 'widgets/settings_menu.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Load environment variables from assets (works on all platforms including Android)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Successfully loaded .env from assets');

    // Verify the API key was loaded
    final apiKey = dotenv.env['OLLAMA_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      debugPrint('OLLAMA_API_KEY loaded successfully');
    } else {
      debugPrint('Warning: OLLAMA_API_KEY not found in .env file');
    }
  } catch (e) {
    debugPrint('Could not load .env file: $e');
    debugPrint('Please ensure .env file is added to pubspec.yaml assets and contains OLLAMA_API_KEY');
  }

  runApp(const BijbelBotApp());
}

class BijbelBotApp extends StatelessWidget {
  const BijbelBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BibleChatProvider(),
      child: MaterialApp(
        title: 'BijbelBot',
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system, // Follow system preference
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('nl'), // Dutch
        ],
        home: const BijbelBotHomePage(),
      ),
    );
  }

  /// Light theme matching original BijbelQuiz app exactly
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB), // Blue primary from original app
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF2563EB), // Blue
        secondary: const Color(0xFF7C3AED), // Purple
        tertiary: const Color(0xFFDC2626), // Red
        surface: const Color(0xFFFAFAFA),
        surfaceContainerHighest: const Color(0xFFF8FAFC),
        onSurface: const Color(0xFF0F172A),
        outline: const Color(0xFFE2E8F0),
        outlineVariant: const Color(0xFFF1F5F9),
        shadow: const Color(0xFF0F172A),
      ),
      useMaterial3: true,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Quicksand',
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFF0F172A),
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Color(0xFF0F172A),
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Color(0xFF0F172A),
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: Color(0xFF0F172A),
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: Color(0xFF0F172A),
        ),
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: Color(0xFF0F172A),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: Color(0xFF334155),
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: Color(0xFF475569),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFF0F172A),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          backgroundColor: const Color(0xFF2563EB), // Blue primary
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
          letterSpacing: -0.1,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    );
  }

  /// Dark theme matching original BijbelQuiz app exactly
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB), // Blue primary from original app
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF2563EB), // Blue
        secondary: const Color(0xFF7C3AED), // Purple
        tertiary: const Color(0xFFDC2626), // Red
        surface: const Color(0xFF0F172A),
        surfaceContainerHighest: const Color(0xFF1E293B),
        onSurface: const Color(0xFFF8FAFC),
        outline: const Color(0xFF334155),
        outlineVariant: const Color(0xFF1E293B),
        shadow: const Color(0xFF000000),
      ),
      useMaterial3: true,
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Quicksand',
        bodyColor: const Color(0xFFF8FAFC),
        displayColor: const Color(0xFFF8FAFC),
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFFF8FAFC),
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Color(0xFFF8FAFC),
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Color(0xFFF8FAFC),
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: Color(0xFFF8FAFC),
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: Color(0xFFF8FAFC),
        ),
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: Color(0xFFF8FAFC),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: Color(0xFFCBD5E1),
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: Color(0xFF94A3B8),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFFF8FAFC),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          backgroundColor: const Color(0xFF2563EB), // Blue primary
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        color: Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
          letterSpacing: -0.1,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
    );
  }
}

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
    // Move initialization to didChangeDependencies where context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  Future<void> _initializeConversation() async {
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    await chatProvider.ensureReady();

    // Create initial conversation if none exists
    if (chatProvider.activeConversation == null) {
      try {
        final conversation = await chatProvider.createConversation(
          title: localizations.newBibleChat,
        );
        setState(() {
          _currentConversation = conversation;
        });
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.errorInitializing} $e'),
              backgroundColor: Colors.red,
            ),
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
    // Set as active conversation in provider
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    chatProvider.setActiveConversation(conversation.id);
  }

  Future<void> _createNewConversation() async {
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    
    try {
      final conversation = await chatProvider.createConversation(
        title: localizations.newConversation,
      );
      setState(() {
        _currentConversation = conversation;
      });
      // Set as active conversation in provider
      chatProvider.setActiveConversation(conversation.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorCreatingConversation} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bibleBot),
        leading: Builder(
          builder: (context) =>
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: localizations.openConversations,
            ),
        ),
        actions: const [
          SettingsMenu(),
        ],
      ),
      drawer: Drawer(
        width: 280,
        child: ConversationHistorySidebar(
          selectedConversationId: _currentConversation?.id,
          onConversationSelected: (conversation) {
            _onConversationSelected(conversation);
            // Close the drawer after selection
            Navigator.of(context).pop();
          },
          onNewConversation: () {
            _createNewConversation();
            // Close the drawer after creating new conversation
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
