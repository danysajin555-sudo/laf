import 'package:flutter/material.dart';

enum ItemType { lost, found }

enum ItemCategory { electronics, books, idCards, clothing, keys, bags, other }

extension ItemCategoryX on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.books:
        return 'Books';
      case ItemCategory.idCards:
        return 'ID / Cards';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.keys:
        return 'Keys';
      case ItemCategory.bags:
        return 'Bags';
      case ItemCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.electronics:
        return Icons.phone_android;
      case ItemCategory.books:
        return Icons.menu_book;
      case ItemCategory.idCards:
        return Icons.badge;
      case ItemCategory.clothing:
        return Icons.checkroom;
      case ItemCategory.keys:
        return Icons.vpn_key;
      case ItemCategory.bags:
        return Icons.backpack;
      case ItemCategory.other:
        return Icons.category;
    }
  }
}

class Item {
  final String id;
  final String title;
  final String description;
  final ItemType type;
  final ItemCategory category;
  final String location;
  final String contact;
  final DateTime date;
  final bool resolved;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.location,
    required this.contact,
    required this.date,
    this.resolved = false,
  });

  Item copyWith({bool? resolved}) => Item(
        id: id,
        title: title,
        description: description,
        type: type,
        category: category,
        location: location,
        contact: contact,
        date: date,
        resolved: resolved ?? this.resolved,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'category': category.name,
        'location': location,
        'contact': contact,
        'date': date.toIso8601String(),
        'resolved': resolved,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: ItemType.values.byName(json['type'] as String),
        category: ItemCategory.values.byName(json['category'] as String),
        location: json['location'] as String,
        contact: json['contact'] as String,
        date: DateTime.parse(json['date'] as String),
        resolved: json['resolved'] as bool? ?? false,
      );
}
