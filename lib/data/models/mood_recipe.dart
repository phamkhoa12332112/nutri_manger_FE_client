import 'package:nutrients_manager/data/models/meal_mood.dart';

import 'ingredients.dart';

class MoodRecipe {
  MealMood recipe;
  List<Ingredient> ingredients;

  MoodRecipe({
    required this.recipe,
    required this.ingredients,
  });

  factory MoodRecipe.fromJson(Map<String, dynamic> json) => MoodRecipe(
    recipe: MealMood.fromJson(json["recipe"]),
    ingredients: List<Ingredient>.from(json["ingredients"].map((x) => Ingredient.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "recipe": recipe.toJson(),
    "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
  };
}