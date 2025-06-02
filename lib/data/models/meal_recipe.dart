import 'package:nutrients_manager/data/models/recipe.dart';

import 'meal.dart';

class MealRecipe {
  Meal meal;
  List<Recipe> recipe;

  MealRecipe({
    required this.meal,
    required this.recipe,
  });

  factory MealRecipe.fromJson(Map<String, dynamic> json) => MealRecipe(
    meal: Meal.fromJson(json["meal"]),
    recipe: [Recipe.fromJson(Map<String, dynamic>.from(json["recipe"]))], // convert Map to List<Recipe>
  );


  Map<String, dynamic> toJson() => {
    "meal": meal.toJson(),
    "recipe": List<dynamic>.from(recipe.map((x) => x.toJson())),
  };
}