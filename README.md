# BijbelBot

A Flutter-based AI-powered Bible chat application that provides biblical answers and references using Ollama's cloud API. The app features a modern Material 3 Expressive design, multi-language support (Dutch and English), and conversation management capabilities.

## Features

- **AI-Powered Bible Q&A**: Ask questions about the Bible and receive answers with biblical references
- **Streaming Responses**: Real-time streaming of AI responses for a better user experience
- **Conversation Management**: Create, switch between, and manage multiple conversations
- **AI-Generated Titles**: Automatically generates conversation titles based on content
- **Message Editing**: Edit user messages and restart conversation from that point
- **Biblical Reference Extraction**: Automatically extracts and highlights Bible references
- **Material 3 Expressive Design**: Modern UI with dynamic color schemes and smooth animations
- **Multi-Language Support**: Dutch and English localization
- **Theme Support**: Light, dark, and system theme modes
- **AI Model Selection**: Choose between different Ollama models (low, medium, high cost)
- **Customizable AI Responses**: Adjust tone, emoji usage, and response format
- **Offline Storage**: Conversations and messages are stored locally using SharedPreferences

## Installation

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- An Ollama API key (get one at [https://ollama.com](https://ollama.com))

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd BijbelBot
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure your API key:
   - Create a `.env` file in the project root
   - Add your Ollama API key:
     ```
     OLLAMA_API_KEY=your_api_key_here
     ```

4. Run the app:
```bash
flutter run
```

## Configuration

### API Key Setup

The app requires an Ollama API key to function. You can obtain one from [https://ollama.com/settings/keys](https://ollama.com/settings/keys).

Add the key to your `.env` file:
```
OLLAMA_API_KEY=your_api_key_here
```

### AI Models

The app supports three Ollama cloud models:

| Model | Cost Tier | Description |
|-------|-----------|-------------|
| Ministral-3 14B | Low | Fast and efficient model for quick responses |
| DeepSeek V3.1 671B | Medium | Balanced model for good quality responses |
| Kimi K2.5 | High | High quality model for detailed responses |

You can change the model in the app settings.

### Prompt Settings

Customize the AI's response style:
- **Tone**: Warm, Professional, or Functional
- **Emoji Level**: More, Normal, or Less
- **Response Format**: Formatted (with structure) or Long Text
- **Custom Instructions**: Add your own instructions for the AI

## Project Structure

```
BijbelBot/
├── lib/
│   ├── main.dart                 # App entry point and theme configuration
│   ├── models/                   # Data models
│   │   ├── ai_model_selection.dart
│   │   ├── ai_prompt_settings.dart
│   │   ├── bible_chat_conversation.dart
│   │   └── bible_chat_message.dart
│   ├── providers/                # State management
│   │   └── bible_chat_provider.dart
│   ├── screens/                  # UI screens
│   │   └── bible_chat_screen.dart
│   ├── services/                 # Business logic and API services
│   │   ├── ai_service.dart
│   │   ├── bible_bot_service.dart
│   │   ├── connection_service.dart
│   │   ├── logger.dart
│   │   ├── system_prompt_config.dart
│   │   └── title_prompt_config.dart
│   ├── utils/                    # Utility functions
│   │   └── bible_book_mapper.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── api_key_dialog.dart
│   │   ├── biblical_reference_dialog.dart
│   │   ├── chat_input_field.dart
│   │   ├── chat_message_bubble.dart
│   │   ├── conversation_history_sidebar.dart
│   │   └── settings_menu.dart
│   ├── assets/                   # Asset files
│   │   ├── system_prompt.json
│   │   └── title_prompt.json
│   └── l10n/                     # Localization files
│       ├── app_en.arb
│       ├── app_nl.arb
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_nl.dart
├── test/                         # Test files
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── macos/                        # macOS platform code
├── linux/                        # Linux platform code
├── windows/                      # Windows platform code
├── pubspec.yaml                  # Dependencies and configuration
├── l10n.yaml                     # Localization configuration
├── AGENTS.md                     # Repository guidelines
├── OLLAMA_SETUP.md               # Ollama setup guide
├── roadmap.md                    # Project roadmap
└── soul.md                       # Theological framework (Dutch)
```

## Architecture

### State Management

The app uses the [Provider](https://pub.dev/packages/provider) package for state management. The main state is managed by [`BibleChatProvider`](lib/providers/bible_chat_provider.dart), which handles:

- Conversation and message storage
- API key management
- AI prompt settings
- Language and theme preferences
- Data persistence

### Services

- **[`AiService`](lib/services/ai_service.dart)**: Handles communication with the Ollama API, including streaming responses and Bible reference extraction
- **[`BibleBotService`](lib/services/bible_bot_service.dart)**: High-level service for Bible Q&A operations
- **[`ConnectionService`](lib/services/connection_service.dart)**: Monitors network connectivity
- **[`AppLogger`](lib/services/logger.dart)**: Logging utility for debugging

### Models

- **[`BibleChatConversation`](lib/models/bible_chat_conversation.dart)**: Represents a chat conversation with metadata
- **[`BibleChatMessage`](lib/models/bible_chat_message.dart)**: Represents an individual message
- **[`AiModel`](lib/models/ai_model_selection.dart)**: Represents an available AI model
- **[`AiPromptSettings`](lib/models/ai_prompt_settings.dart)**: Configuration for AI response style

### UI Components

- **[`BibleChatScreen`](lib/screens/bible_chat_screen.dart)**: Main chat interface
- **[`ChatMessageBubble`](lib/widgets/chat_message_bubble.dart)**: Displays individual messages
- **[`ChatInputField`](lib/widgets/chat_input_field.dart)**: Message input component
- **[`ConversationHistorySidebar`](lib/widgets/conversation_history_sidebar.dart)**: Conversation list sidebar
- **[`SettingsMenu`](lib/widgets/settings_menu.dart)**: App settings menu

## Development

### Build Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d windows         # Windows

# Build for release
flutter build apk              # Android APK
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS
flutter build windows          # Windows
flutter build linux            # Linux

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib test
```

### Code Style

- 2-space indentation
- `lowerCamelCase` for members and variables
- `PascalCase` for classes and widgets
- Follow [`analysis_options.yaml`](analysis_options.yaml) lint rules
- Run `dart format` before committing

### Testing

Tests are located in the `test/` directory and follow the `*_test.dart` naming convention.

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Localization

The app supports Dutch and English languages. To add a new language:

1. Create a new `.arb` file in `lib/l10n/` (e.g., `app_de.arb`)
2. Add translations following the existing format
3. Update `l10n.yaml` to include the new locale
4. Run `flutter gen-l10n` to generate localization classes
5. Update [`main.dart`](lib/main.dart) to include the new locale in `supportedLocales`

## Theological Framework

The app uses a specific theological framework defined in [`soul.md`](soul.md). This document outlines:

- Biblical and confessional foundations
- Covenant and grace theology
- Reformed theological principles
- Life and behavioral guidelines
- Comparison with other Reformed churches

This framework is loaded and used as context for AI responses to ensure theological consistency.

## Troubleshooting

### Common Issues

**"API key ontbreekt" (API key missing)**
- Ensure your Ollama API key is set in the `.env` file
- Add the key through the app settings

**"Model niet gevonden" (Model not found)**
- Verify the selected model is available on Ollama
- Try switching to a different model in settings

**Connection errors**
- Check your internet connection
- Verify the Ollama API status at [https://status.ollama.com](https://status.ollama.com)

**Empty conversations not deleted**
- Empty conversations are kept for 10 minutes before cleanup
- This prevents accidental deletion of new conversations
