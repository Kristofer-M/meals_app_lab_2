class MealSummary {
  final String id;
  final String name;
  final String thumbnail;

  MealSummary({required this.id, required this.name, required this.thumbnail});

  factory MealSummary.fromJson(Map<String, dynamic> j) => MealSummary(
    id: j['idMeal'] as String,
    name: j['strMeal'] as String,
    thumbnail: j['strMealThumb'] as String,
  );
}
