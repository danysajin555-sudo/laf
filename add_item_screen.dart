import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../services/item_repository.dart';

class AddItemScreen extends StatefulWidget {
  final ItemRepository repo;
  const AddItemScreen({super.key, required this.repo});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();

  ItemType _type = ItemType.lost;
  ItemCategory _category = ItemCategory.other;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final item = Item(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      category: _category,
      location: _location.text.trim(),
      contact: _contact.text.trim(),
      date: _date,
    );
    await widget.repo.add(item);
    if (mounted) Navigator.pop(context);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ItemType>(
              segments: const [
                ButtonSegment(
                    value: ItemType.lost,
                    label: Text('I lost something'),
                    icon: Icon(Icons.search_off)),
                ButtonSegment(
                    value: ItemType.found,
                    label: Text('I found something'),
                    icon: Icon(Icons.check_circle_outline)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Item name', border: OutlineInputBorder()),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ItemCategory>(
              value: _category,
              decoration: const InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
              items: [
                for (final c in ItemCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description (colour, brand, marks...)',
                  border: OutlineInputBorder()),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: InputDecoration(
                  labelText: _type == ItemType.lost
                      ? 'Where did you lose it?'
                      : 'Where did you find it?',
                  border: const OutlineInputBorder()),
              validator: _required,
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4)),
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(_date)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contact,
              decoration: const InputDecoration(
                  labelText: 'Contact (email / phone / office)',
                  border: OutlineInputBorder()),
              validator: _required,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
