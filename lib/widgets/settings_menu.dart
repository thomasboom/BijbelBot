import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_chat_provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) async {
        final provider = Provider.of<BibleChatProvider>(context, listen: false);
        
        if (result == 'delete_all_chats') {
          _showDeleteAllChatsDialog(context, provider);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'delete_all_chats',
          child: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 12),
              Text('Verwijder alle gesprekken', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
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