import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../models/meal_detail.dart';

class RecipeScreen extends StatefulWidget {
  final String mealId;
  const RecipeScreen({super.key, required this.mealId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final ApiService api = ApiService();
  final FavoriteService favService = FavoriteService();

  late Future<MealDetail> _future;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _future = api.lookupMeal(widget.mealId);
    _checkFavorite();
  }

  void _checkFavorite() async {
    final fav = await favService.isFavorite(widget.mealId);
    if (mounted) {
      setState(() {
        isFavorite = fav;
      });
    }
  }

  void _toggleFavorite(MealDetail meal) {
    favService.toggleFavorite(
      meal.id,
      meal.name,
      meal.thumbnail,
    );
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _openYoutube(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        actions: [
          FutureBuilder<MealDetail>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              final meal = snapshot.data!;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                ),
                onPressed: () => _toggleFavorite(meal),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<MealDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final meal = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CachedNetworkImage(
                  imageUrl: meal.thumbnail,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 12),
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (meal.area.isNotEmpty || meal.category.isNotEmpty)
                  Text('${meal.area} • ${meal.category}'),
                const SizedBox(height: 12),

                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(meal.instructions),
                const SizedBox(height: 12),

                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...meal.ingredients.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- ${e.key}: ${e.value}'),
                  ),
                ),

                const SizedBox(height: 12),
                if (meal.youtube.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openYoutube(meal.youtube),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Watch on YouTube'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
