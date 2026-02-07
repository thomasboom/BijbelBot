import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_chat_provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => _showSettingsBottomSheet(context),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Verwijder alle gesprekken',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  final provider = Provider.of<BibleChatProvider>(context, listen: false);
                  _showDeleteAllChatsDialog(context, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllChatsDialog(BuildContext context, BibleChatProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alle gesprekken verwijderen'),
          content: const Text(
            'Weet u zeker dat u alle gesprekken wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await provider.clearAllData();
                
                // Show confirmation
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alle gesprekken zijn verwijderd'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Verwijderen', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
