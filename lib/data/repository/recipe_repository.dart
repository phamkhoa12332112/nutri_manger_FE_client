import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/recipe_ingredient_meal.dart';

import '../models/recipe.dart';

abstract class RecipeRepository{
  Future<Recipe> fetchRecipe(int recipeId);
}


class RecipeRepositoryImp implements RecipeRepository {
  static final RecipeRepositoryImp _instance = RecipeRepositoryImp._internal();
  static RecipeRepositoryImp get instance => _instance;

  final String baseUrl = 'http://10.0.2.2:3003';

  RecipeRepositoryImp._internal();

  @override
  Future<Recipe> fetchRecipe(int recipeId) async {
    final url = Uri.parse('$baseUrl/recipes/$recipeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Recipe.fromJson(data['data']);
    } else {
      throw Exception('Failed to fetch meals: ${response.body}');
    }
  }

  Future<RecipeIngredientMeal> fetchRecipeToGetMeal(int recipeId) async {
    final url = Uri.parse('$baseUrl/recipes/$recipeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RecipeIngredientMeal.fromJson(data['data']);
    } else {
      throw Exception('Failed to fetch meals: ${response.body}');
    }
  }
}
