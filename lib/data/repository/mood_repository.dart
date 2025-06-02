import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/ingredients.dart';
import 'package:nutrients_manager/data/models/mood.dart';
import 'package:nutrients_manager/data/models/mood_recipe.dart';

import '../models/meal_mood.dart';
import '../models/recipe.dart';

abstract class MoodRepository {
  Future<List<Mood>> fetchAllMoods();

  Future<List<MoodRecipe>> fetchMoodRecipes(int moodId);
}

class MoodRepositoryImp implements MoodRepository {
  static final MoodRepositoryImp _instance = MoodRepositoryImp._internal();

  static MoodRepositoryImp get instance => _instance;

  final String baseUrl = 'http://10.0.2.2:3003';

  MoodRepositoryImp._internal();

  @override
  Future<List<Mood>> fetchAllMoods() async {
    final url = Uri.parse('$baseUrl/moods');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> moodList = data['data'];

      return moodList.map((item) => Mood.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch moods: ${response.body}');
    }
  }

  @override
  Future<List<MoodRecipe>> fetchMoodRecipes(int moodId) async {
    final url = Uri.parse('$baseUrl/moods/$moodId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> moodRecipeList = data['data'];
      return moodRecipeList.map((item) {
        final mealMood = MealMood.fromJson(item['recipe']);
        final ingredientsJson = item['ingredients'];
        final ingredients = (ingredientsJson != null && ingredientsJson is List)
            ? ingredientsJson.map((r) => Ingredient.fromJson(r)).toList()
            : <Ingredient>[];
        return MoodRecipe(recipe: mealMood, ingredients: ingredients);
      }).toList();
    } else {
      throw Exception('Failed to fetch recipe for moods: ${response.body}');
    }
  }
}
