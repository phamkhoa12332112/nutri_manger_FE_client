import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/meal_recipe.dart';

import '../models/meal.dart';
import '../models/recipe.dart';

abstract class MealRepository {
  Future<List<MealRecipe>> fetchAllMealsWithRecipes();
  Future<void> addMealWithRecipes(MealRecipe mealData);
}


class MealRepositoryImpl implements MealRepository {
  static final MealRepositoryImpl _instance = MealRepositoryImpl._internal();
  static MealRepositoryImpl get instance => _instance;

  final String baseUrl = 'http://10.0.2.2:3003';

  MealRepositoryImpl._internal();

  @override
  Future<void> addMealWithRecipes(MealRecipe mealData) async {
    final url = Uri.parse('$baseUrl/meals/create-with-recipes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(mealData.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add meal with recipes: ${response.body}');
    }
  }

  @override
  Future<List<MealRecipe>> fetchAllMealsWithRecipes() async {
    final url = Uri.parse('$baseUrl/meals');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> mealsList = data['data'];

      return mealsList.map((item) {
        final meal = Meal.fromJson(item['meal']);
        final recipes = (item['recipe'] as List)
            .map((r) => Recipe.fromJson(r))
            .toList();

        return MealRecipe(meal: meal, recipe: recipes);
      }).toList();
    } else {
      throw Exception('Failed to fetch meals: ${response.body}');
    }
  }
}
