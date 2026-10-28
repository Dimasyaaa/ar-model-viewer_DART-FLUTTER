import 'package:flutter/material.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';

class HomeScreen extends StatefulWidget {
  final ModelRepository repository;
  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ArModel> _models = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final models = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is RepositoryException
            ? e.message
            : 'Ошибка загрузки данных';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Catalog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadModels,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              )
            : _models.isEmpty
            ? const Center(child: Text('Каталог пуст'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  final model = _models[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.asset(
                        model.previewPath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                      title: Text(model.title),
                      subtitle: Text(model.description),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Сканирование QR будет в ЛР7')),
          );
        },
        label: const Text('Сканировать QR'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
