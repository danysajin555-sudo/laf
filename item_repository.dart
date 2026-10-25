import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';

/// Stores items locally on the device. To go multi-user later, replace the
/// body of load/add/toggleResolved/remove with Firebase or REST API calls;
/// the screens only talk to this class.
class ItemRepository extends ChangeNotifier {
  static const _key = 'items_v1';

  final List<Item> _items = [];
  List<Item> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items
        ..clear()
        ..addAll(list.map(Item.fromJson));
    } else {
      _items.addAll(_sampleData());
    }
    notifyListeners();
  }

  Future<void> add(Item item) async {
    _items.insert(0, item);
    await _save();
  }

  Future<void> toggleResolved(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(resolved: !_items[i].resolved);
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> _save() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  List<Item> _sampleData() {
    final now = DateTime.now();
    return [
      Item(
        id: '1',
        title: 'Black wallet',
        description: 'Leather wallet with a student ID inside.',
        type: ItemType.lost,
        category: ItemCategory.idCards,
        location: 'Library, 2nd floor',
        contact: 'ravi@college.edu',
        date: now.subtract(const Duration(days: 1)),
      ),
      Item(
        id: '2',
        title: 'Blue water bottle',
        description: 'Found near the cafeteria entrance.',
        type: ItemType.found,
        category: ItemCategory.other,
        location: 'Cafeteria',
        contact: 'Security desk, Block A',
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
