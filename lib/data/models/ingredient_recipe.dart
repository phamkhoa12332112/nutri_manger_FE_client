import 'ingredients.dart';
import 'meal_recipe.dart';

class IngredientRecipe {
  MealRecipe mealRecipe;
  List<Ingredient> ingredients;

  IngredientRecipe({required this.mealRecipe, required this.ingredients});

  factory IngredientRecipe.fromJson(Map<String, dynamic> json) =>
      IngredientRecipe(
        mealRecipe: MealRecipe.fromJson(json["mealRecipe"]),
        ingredients: List<Ingredient>.from(
          json["ingredients"].map((x) => Ingredient.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "mealRecipe": mealRecipe.toJson(),
    "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
  };
}
