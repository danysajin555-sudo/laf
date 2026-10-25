import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/item_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ItemRepository();
  await repo.load();
  runApp(LostFoundApp(repo: repo));
}

class LostFoundApp extends StatelessWidget {
  final ItemRepository repo;
  const LostFoundApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: HomeScreen(repo: repo),
    );
  }
}
