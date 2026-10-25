import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../services/item_repository.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemRepository repo;
  final String itemId;
  const ItemDetailScreen(
      {super.key, required this.repo, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final matches = repo.items.where((e) => e.id == itemId);
        if (matches.isEmpty) return const Scaffold(body: SizedBox());
        final item = matches.first;
        final isLost = item.type == ItemType.lost;

        return Scaffold(
          appBar: AppBar(
            title: Text(isLost ? 'Lost item' : 'Found item'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete this post?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await repo.remove(item.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        isLost ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(item.category.icon,
                        color: isLost ? Colors.red : Colors.green, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(item.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (item.resolved)
                const Chip(
                    avatar: Icon(Icons.check, size: 16),
                    label: Text('Resolved')),
              const SizedBox(height: 8),
              Text(item.description),
              const Divider(height: 32),
              _row(Icons.category, 'Category', item.category.label),
              _row(Icons.place, isLost ? 'Lost at' : 'Found at', item.location),
              _row(Icons.calendar_today, 'Date',
                  DateFormat.yMMMMd().format(item.date)),
              _row(Icons.contact_phone, 'Contact', item.contact),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy contact'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.contact));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact copied')));
                },
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: Icon(item.resolved ? Icons.undo : Icons.check_circle),
                label: Text(item.resolved
                    ? 'Mark as unresolved'
                    : (isLost ? 'Mark as found / returned' : 'Mark as claimed')),
                onPressed: () => repo.toggleResolved(item.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
