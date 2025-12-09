import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal_summary.dart';
import '../widgets/meal_grid_item.dart';
import 'recipe_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService api = ApiService();
  late Future<List<MealSummary>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchMealsByCategory(widget.category);
  }

  void _performSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _future = api.fetchMealsByCategory(widget.category));
      return;
    }
    setState(() => _future = api.searchMeals(q));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search dishes',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                _search = v;
                _performSearch(v);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MealSummary>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('No results'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final m = list[idx];
                    return MealGridItem(
                      meal: m,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeScreen(mealId: m.id),
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
