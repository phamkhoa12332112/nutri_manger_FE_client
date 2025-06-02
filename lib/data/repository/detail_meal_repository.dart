import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/ingredient_recipe.dart';
import 'package:nutrients_manager/data/models/meal_recipe.dart';

import '../models/ingredients.dart';

abstract class DetailMealRepository {
  Future<IngredientRecipe> fetchDetailMeal(int mealId, int recipeId, int userId);
}


class DetailMealRepositoryImp implements DetailMealRepository {
  static final DetailMealRepositoryImp _instance = DetailMealRepositoryImp._internal();
  static DetailMealRepositoryImp get instance => _instance;

  final String baseUrl = 'http://10.0.2.2:3003';

  DetailMealRepositoryImp._internal();


  @override
  Future<IngredientRecipe> fetchDetailMeal(int mealId, int recipeId, int userId) async {
    final url = Uri.parse('$baseUrl/meals/details/$mealId/$recipeId?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> detailMeal = data['data'];
      MealRecipe mealRecipe = MealRecipe.fromJson(detailMeal['mealRecipe']);
      List<Ingredient> ingredients = (detailMeal['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList();

      return IngredientRecipe(
        mealRecipe: mealRecipe,
        ingredients: ingredients,
      );


    } else {
      throw Exception('Failed to fetch detail meal: ${response.body}');
    }
  }
}
