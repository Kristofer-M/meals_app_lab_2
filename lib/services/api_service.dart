import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/categories.php'));
    if (res.statusCode != 200) throw Exception('Failed to load categories');
    final Map<String, dynamic> parsed = jsonDecode(res.body);
    final List items = parsed['categories'] as List;
    return items.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final res = await http.get(
      Uri.parse('$_base/filter.php?c=${Uri.encodeComponent(category)}'),
    );
    if (res.statusCode != 200) throw Exception('Failed to load meals');
    final Map<String, dynamic> parsed = jsonDecode(res.body);
    final List? items = parsed['meals'] as List?;
    if (items == null) return [];
    return items.map((e) => MealSummary.fromJson(e)).toList();
  }

  Future<List<MealSummary>> searchMeals(String query) async {
    final res = await http.get(
      Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}'),
    );
    if (res.statusCode != 200) throw Exception('Search failed');
    final Map<String, dynamic> parsed = jsonDecode(res.body);
    final List? items = parsed['meals'] as List?;
    if (items == null) return [];
    return items.map((e) => MealSummary.fromJson(e)).toList();
  }

  Future<MealDetail> lookupMeal(String id) async {
    final res = await http.get(
      Uri.parse('$_base/lookup.php?i=${Uri.encodeComponent(id)}'),
    );
    if (res.statusCode != 200) throw Exception('Lookup failed');
    final Map<String, dynamic> parsed = jsonDecode(res.body);
    final List items = parsed['meals'] as List;
    return MealDetail.fromJson(items[0]);
  }

  Future<MealDetail> randomMeal() async {
    final res = await http.get(Uri.parse('$_base/random.php'));
    if (res.statusCode != 200) throw Exception('Random failed');
    final Map<String, dynamic> parsed = jsonDecode(res.body);
    final List items = parsed['meals'] as List;
    return MealDetail.fromJson(items[0]);
  }
}
