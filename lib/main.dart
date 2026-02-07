import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/bible_chat_conversation.dart';
import 'providers/bible_chat_provider.dart';
import 'screens/bible_chat_screen.dart';
import 'widgets/conversation_history_sidebar.dart';
import 'widgets/settings_menu.dart';
import 'l10n/app_localizations.dart';

void main() async {
  runApp(const BijbelBotApp());
}

/// Material 3 Expressive theme configuration for BijbelBot
/// 
/// This implementation follows M3 Expressive guidelines:
/// - Dynamic color schemes from seed color
/// - Proper M3 type scale with correct line heights
/// - Shape system using M3 shape scale
/// - Expressive motion with proper easing curves
class BijbelBotApp extends StatelessWidget {
  const BijbelBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BibleChatProvider(),
      child: MaterialApp(
        title: 'BijbelBot',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('nl'),
        ],
        home: const BijbelBotHomePage(),
      ),
    );
  }

  /// Material 3 Expressive Light Theme
  /// 
  /// Uses dynamic color generation from seed color with proper M3 color roles.
  /// Typography follows M3 type scale with expressive font weights.
  /// Shape system uses M3 shape scale for consistent corner radii.
  ThemeData _buildLightTheme() {
    // M3 Expressive seed color - vibrant blue for spiritual/biblical app
    const seedColor = Color(0xFF2563EB);
    
    // Generate dynamic color scheme from seed
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // M3 Expressive Typography Scale
      // Following exact M3 type scale specifications
      textTheme: _buildM3TextTheme(Brightness.light, colorScheme),
      
      // M3 Expressive Shape System
      // Using M3 shape scale: extraSmall (4dp), small (8dp), medium (12dp), large (16dp), extraLarge (28dp)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // large component
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerHighest,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      
      // Elevated Button - M3 Expressive style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // extraLarge for buttons
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Filled Button - M3 style
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Text Button - M3 style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // AppBar - M3 Expressive style with scroll elevation
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          letterSpacing: 0,
        ),
      ),
      
      // Navigation Drawer - M3 style
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(28), // extraLarge
          ),
        ),
      ),
      
      // Bottom Sheet - M3 Expressive style
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28), // extraLarge
          ),
        ),
      ),
      
      // Dialog - M3 style
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // extraLarge
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      // SnackBar - M3 style
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Input Decoration - M3 Expressive style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // extraLarge for text fields
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Page Transitions - M3 Expressive motion
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  /// Material 3 Expressive Dark Theme
  ThemeData _buildDarkTheme() {
    // M3 Expressive seed color - same as light for consistency
    const seedColor = Color(0xFF2563EB);
    
    // Generate dynamic color scheme from seed for dark mode
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // M3 Expressive Typography Scale
      textTheme: _buildM3TextTheme(Brightness.dark, colorScheme),
      
      // M3 Expressive Shape System
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerHighest,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          letterSpacing: 0,
        ),
      ),
      
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(28),
          ),
        ),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  /// Build M3 Expressive Typography Scale
  /// 
  /// M3 Type Scale specifications:
  /// - Display: Large (57), Medium (45), Small (36)
  /// - Headline: Large (32), Medium (28), Small (24)
  /// - Title: Large (22), Medium (16), Small (14)
  /// - Body: Large (16), Medium (14), Small (12)
  /// - Label: Large (14), Medium (12), Small (11)
  TextTheme _buildM3TextTheme(Brightness brightness, ColorScheme colorScheme) {
    final isDark = brightness == Brightness.dark;
    final onSurfaceColor = isDark ? colorScheme.onSurface : colorScheme.onSurface;
    final onSurfaceVariant = isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant;
    
    return TextTheme(
      // Display styles - for large, short text like onboarding
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: -0.25,
        color: onSurfaceColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      
      // Headline styles - for section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.29,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      
      // Title styles - for component titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 1.27,
        letterSpacing: 0,
        color: onSurfaceColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.15,
        color: onSurfaceColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: onSurfaceColor,
      ),
      
      // Body styles - for longer content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: onSurfaceVariant,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: onSurfaceVariant,
      ),
      
      // Label styles - for buttons, inputs, etc.
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: onSurfaceColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: onSurfaceColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: onSurfaceColor,
      ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  Future<void> _initializeConversation() async {
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

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
            SnackBar(
              content: Text('${localizations.errorInitializing} $e'),
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
