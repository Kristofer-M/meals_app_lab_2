class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtube;
  final Map<String, String> ingredients; // ingredient -> measure

  MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtube,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> j) {
    final Map<String, String> ingr = {};
    for (var i = 1; i <= 20; i++) {
      final ing = j['strIngredient\$i'];
      final mea = j['strMeasure\$i'];
      if (ing != null && (ing as String).trim().isNotEmpty) {
        ingr[ing] = (mea as String?)?.trim() ?? '';
      }
    }

    return MealDetail(
      id: j['idMeal'] as String,
      name: j['strMeal'] as String,
      category: j['strCategory'] as String? ?? '',
      area: j['strArea'] as String? ?? '',
      instructions: j['strInstructions'] as String? ?? '',
      thumbnail: j['strMealThumb'] as String? ?? '',
      youtube: j['strYoutube'] as String? ?? '',
      ingredients: ingr,
    );
  }
}
