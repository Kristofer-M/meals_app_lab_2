import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'category_screen.dart';
import 'recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  late Future<List<Category>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchCategories();
  }

  void _openRandom() async {
    final meal = await api.randomMeal();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeScreen(mealId: meal.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(onPressed: _openRandom, icon: const Icon(Icons.shuffle)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search categories',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final list = snapshot.data ?? [];
                final filtered = list
                    .where((c) =>
                        c.name.toLowerCase().contains(_search.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final cat = filtered[idx];
                    return ListTile(
                      leading: Image.network(cat.thumbnail),
                      title: Text(cat.name),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(category: cat.name),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
