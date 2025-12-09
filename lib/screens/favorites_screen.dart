import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/notification_service.dart';
import 'recipe_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Favorites list
        Expanded(
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: FavoriteService().favoritesNotifier,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const Center(child: Text("No favorites yet"));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Image.network(item['thumbnail']),
                    title: Text(item['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        FavoriteService().removeFavorite(item['id']);
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeScreen(mealId: item['id']),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Test notification button
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: ElevatedButton(
        //     onPressed: () => NotificationService().testNotificationNow(),
        //     child: const Text('Test Notification Now'),
        //   ),
        // ),
      ],
    );
  }
}
