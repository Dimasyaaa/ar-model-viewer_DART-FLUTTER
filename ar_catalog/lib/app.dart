import 'package:flutter/material.dart';
import 'package:ar_catalog/screens/home_screen.dart';
import 'package:ar_catalog/repositories/model_repository.dart';

class ArCatalogApp extends StatelessWidget {
  final ModelRepository repository;

  const ArCatalogApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Catalog', // название
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: repository), // начальный экран
    );
  }
}
