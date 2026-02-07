import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:xml/xml.dart' as xml;
import '../constants/urls.dart';
import '../utils/bible_book_mapper.dart';

/// M3 Expressive biblical reference dialog
/// 
/// Features:
/// - M3 dialog shape with extraLarge corner radius
/// - Dynamic color from theme colorScheme
/// - M3 typography scale
/// - Expressive loading and error states
class BiblicalReferenceDialog extends StatefulWidget {
  final String reference;

  const BiblicalReferenceDialog({super.key, required this.reference});

  @override
  State<BiblicalReferenceDialog> createState() => _BiblicalReferenceDialogState();
}

class _BiblicalReferenceDialogState extends State<BiblicalReferenceDialog> {
  bool _isLoading = true;
  String _content = '';
  String _error = '';

  final http.Client _client = http.Client();

  @override
  void initState() {
    super.initState();
    _loadBiblicalReference();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadBiblicalReference() async {
    try {
      final parsed = _parseReference(widget.reference);
      if (parsed == null) {
        final localizations = AppLocalizations.of(context)!;
        throw Exception(localizations.invalidBiblicalReferenceWithRef(widget.reference));
      }

      final book = parsed['book'];
      final chapter = parsed['chapter'];
      final startVerse = parsed['startVerse'];
      final endVerse = parsed['endVerse'];

      final bookNumber = BibleBookMapper.getBookNumber(book);
      if (bookNumber == null) {
        final localizations = AppLocalizations.of(context)!;
        final validBooks = BibleBookMapper.getAllBookNames();
        throw Exception(localizations.invalidBookName(book, validBooks.take(10).join(", ")));
      }

      String url;
      if (startVerse != null && endVerse != null) {
        url = '${AppUrls.bibleApiBase}?b=$bookNumber&h=$chapter&v=$startVerse-$endVerse';
      } else if (startVerse != null) {
        url = '${AppUrls.bibleApiBase}?b=$bookNumber&h=$chapter&v=$startVerse';
      } else {
        url = '${AppUrls.bibleApiBase}?b=$bookNumber&h=$chapter&v=1-10';
      }

      final uri = Uri.parse(url);
      if (uri.host != Uri.parse(AppUrls.bibleApiBase).host) {
        throw Exception('invalid_api_url');
      }

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('timeout_error');
        },
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType == null || (!contentType.contains('xml') && !contentType.contains('text'))) {
          throw Exception('invalid_content_type');
        }

        String content = '';
        try {
          String cleanBody = response.body.trim();
          if (cleanBody.startsWith('\uFEFF')) {
            cleanBody = cleanBody.substring(1);
          }

          final document = xml.XmlDocument.parse(cleanBody);
          final verses = document.findAllElements('vers');

          for (final verse in verses) {
            final verseNumber = verse.getAttribute('name');
            final verseText = verse.innerText.trim();

            if (verseNumber != null && verseText.isNotEmpty) {
              final sanitizedText = _sanitizeText(verseText);
              content += '$verseNumber. $sanitizedText\n';
            }
          }

          if (content.isEmpty) {
            final alternativeVerseElements = document.findAllElements('verse');
            for (final verse in alternativeVerseElements) {
              final verseNumber = verse.getAttribute('name') ?? verse.getAttribute('number');
              final verseText = verse.innerText.trim();

              if (verseNumber != null && verseText.isNotEmpty) {
                final sanitizedText = _sanitizeText(verseText);
                content += '$verseNumber. $sanitizedText\n';
              }
            }
          }

          if (content.isEmpty) {
            final allElements = <xml.XmlElement>[];
            _collectAllElements(document.rootElement, allElements);

            for (final element in allElements) {
              final elementText = element.innerText.trim();
              if (elementText.isNotEmpty &&
                  elementText.length > 10 &&
                  !elementText.contains('<') &&
                  !elementText.contains('xml') &&
                  !elementText.contains('bijbel')) {
                final sanitizedText = _sanitizeText(elementText);
                content += '$sanitizedText\n';
              }
            }
          }

          if (content.isEmpty) {
            throw Exception('no_text_found');
          }
        } catch (e) {
          String extractedText = _extractTextFromResponse(response.body);
          if (extractedText.isNotEmpty) {
            content = _sanitizeText(extractedText);
          } else {
            throw Exception('xml_parsing_failed');
          }
        }

        if (mounted) {
          setState(() {
            _content = content;
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 429) {
        throw Exception('too_many_requests');
      } else {
        throw Exception('server_error_${response.statusCode}');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          _error = 'network_error';
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (e.toString().contains('Time-out')) {
        if (mounted) {
          setState(() {
            _error = 'timeout_error';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'error_loading_with_details';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'error_loading_with_details';
          _isLoading = false;
        });
      }
    }
  }

  String _sanitizeText(String text) {
    String decodedText = _decodeUnicodeEscapes(text);

    return decodedText
        .replaceAll('&', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .replaceAll('"', '"')
        .replaceAll("'", '&#x27;');
  }

  String _decodeUnicodeEscapes(String text) {
    final RegExp unicodeRegex = RegExp(r'\u([0-9a-fA-F]{4})');
    return text.replaceAllMapped(unicodeRegex, (Match match) {
      final String hexCode = match.group(1)!;
      final int charCode = int.parse(hexCode, radix: 16);
      return String.fromCharCode(charCode);
    });
  }

  void _collectAllElements(xml.XmlElement element, List<xml.XmlElement> collection) {
    collection.add(element);
    for (final child in element.childElements) {
      _collectAllElements(child, collection);
    }
  }

  String _extractTextFromResponse(String responseBody) {
    try {
      if (responseBody.contains('<') && responseBody.contains('>')) {
        final document = xml.XmlDocument.parse(responseBody);
        final allElements = <xml.XmlElement>[];
        _collectAllElements(document.rootElement, allElements);

        for (final element in allElements) {
          final text = element.innerText.trim();
          if (text.isNotEmpty && text.length > 10) {
            return text;
          }
        }
      }

      return responseBody.trim();
    } catch (e) {
      return responseBody.trim();
    }
  }

  Map<String, dynamic>? _parseReference(String reference) {
    try {
      reference = reference.trim();

      if (reference.contains(' en ')) {
        final parts = reference.split(' en ');
        if (parts.length == 2) {
          final firstPart = parts[0].trim();
          final secondPart = parts[1].trim();

          final firstMatch = RegExp(r'(\w+)\s+(\d+)').firstMatch(firstPart);
          if (firstMatch != null) {
            final book = firstMatch.group(1)!;
            final chapter = int.tryParse(firstMatch.group(2)!);

            final secondMatch = RegExp(r'(\d+)').firstMatch(secondPart);
            if (secondMatch != null) {
              return {
                'book': book,
                'chapter': chapter,
                'startVerse': null,
                'endVerse': null,
              };
            }
          }
        }
      }

      final parts = reference.split(' ');
      if (parts.length < 2) {
        if (BibleBookMapper.isValidBookName(reference)) {
          return {
            'book': reference,
            'chapter': 1,
            'startVerse': null,
            'endVerse': null,
          };
        }
        return null;
      }

      final book = parts.sublist(0, parts.length - 1).join(' ');
      final chapterAndVerses = parts.last;

      final chapterVerseParts = chapterAndVerses.split(':');

      if (chapterVerseParts.isEmpty) return null;

      final chapter = int.tryParse(chapterVerseParts[0]);
      if (chapter == null) return null;

      int? startVerse;
      int? endVerse;

      if (chapterVerseParts.length > 1) {
        final versePart = chapterVerseParts[1];
        if (versePart.contains('-')) {
          final verseRange = versePart.split('-');
          startVerse = int.tryParse(verseRange[0]);
          endVerse = int.tryParse(verseRange[1]);
        } else {
          startVerse = int.tryParse(versePart);
        }
      }

      return {
        'book': book,
        'chapter': chapter,
        'startVerse': startVerse,
        'endVerse': endVerse,
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    String displayError = _error;
    
    switch (_error) {
      case 'network_error':
        displayError = localizations.networkError;
        break;
      case 'timeout_error':
        displayError = localizations.timeoutError;
        break;
      case 'invalid_api_url':
        displayError = localizations.invalidApiUrl;
        break;
      case 'invalid_content_type':
        displayError = '${localizations.invalidContentType}. Content-Type: ... Response: ...';
        break;
      case 'no_text_found':
        displayError = localizations.noTextFound;
        break;
      case 'xml_parsing_failed':
        displayError = localizations.xmlParsingFailed;
        break;
      case 'too_many_requests':
        displayError = localizations.tooManyRequests;
        break;
      case 'error_loading_with_details':
        displayError = localizations.errorLoadingWithDetails;
        break;
      default:
        if (_error.startsWith('server_error_')) {
          final statusCode = _error.replaceFirst('server_error_', '');
          displayError = '${localizations.serverError} $statusCode)';
        }
    }
    
    return AlertDialog(
      icon: _isLoading 
          ? null 
          : (_error.isNotEmpty 
              ? Icon(Icons.error_outline, color: colorScheme.error, size: 32)
              : Icon(Icons.menu_book_outlined, color: colorScheme.primary, size: 32)),
      title: Text(
        localizations.biblicalReference,
        style: textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.loading,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : displayError.isNotEmpty
                ? Text(displayError, style: textTheme.bodyMedium)
                : SingleChildScrollView(
                    child: SelectableText(
                      _content,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.close),
        ),
      ],
    );
  }
}
