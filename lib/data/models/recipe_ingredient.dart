import 'package:nutrients_manager/data/models/ingredient_meal.dart';

class RecipeIngredient {
  int id;
  int quantity;
  IngredientMeal ingredient;

  RecipeIngredient({
    required this.id,
    required this.quantity,
    required this.ingredient,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
    id: json["id"],
    quantity: json["quantity"],
    ingredient: IngredientMeal.fromJson(json["ingredient"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "ingredient": ingredient.toJson(),
  };
}