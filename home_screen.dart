import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../services/item_repository.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ItemRepository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  ItemCategory? _category;

  List<Item> _filtered(ItemType? type) {
    final q = _query.toLowerCase();
    final list = widget.repo.items.where((i) {
      if (type != null && i.type != type) return false;
      if (_category != null && i.category != _category) return false;
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) {
      if (a.resolved != b.resolved) return a.resolved ? 1 : -1;
      return b.date.compareTo(a.date);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campus Lost & Found'),
          bottom: const TabBar(tabs: [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search items, places...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final c in ItemCategory.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(c.label),
                        avatar: Icon(c.icon, size: 16),
                        selected: _category == c,
                        onSelected: (s) =>
                            setState(() => _category = s ? c : null),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.repo,
                builder: (context, _) => TabBarView(children: [
                  _buildList(_filtered(null)),
                  _buildList(_filtered(ItemType.lost)),
                  _buildList(_filtered(ItemType.found)),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Report'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(repo: widget.repo),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Item> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLost = item.type == ItemType.lost;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isLost ? Colors.red.shade100 : Colors.green.shade100,
              child: Icon(item.category.icon,
                  color: isLost ? Colors.red : Colors.green),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration:
                    item.resolved ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
                '${item.location} • ${DateFormat.MMMd().format(item.date)}'),
            trailing: item.resolved
                ? const Chip(label: Text('Resolved'))
                : Chip(
                    label: Text(isLost ? 'LOST' : 'FOUND'),
                    backgroundColor:
                        isLost ? Colors.red.shade50 : Colors.green.shade50,
                  ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ItemDetailScreen(repo: widget.repo, itemId: item.id),
              ),
            ),
          ),
        );
      },
    );
  }
}
