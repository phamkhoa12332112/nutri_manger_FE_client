import 'package:nutrients_manager/data/models/recipe_ingredient.dart';

import 'meal_items.dart';
class RecipeIngredientMeal {
  int id;
  String name;
  String description;
  double totalCalories;
  String imageUrl;
  List<RecipeIngredient> items;
  List<MealItem> mealItems;

  RecipeIngredientMeal({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCalories,
    required this.imageUrl,
    required this.items,
    required this.mealItems,
  });

  factory RecipeIngredientMeal.fromJson(Map<String, dynamic> json) => RecipeIngredientMeal(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    totalCalories: json["totalCalories"]?.toDouble(),
    imageUrl: json["imageUrl"],
    items: List<RecipeIngredient>.from(json["items"].map((x) => RecipeIngredient.fromJson(x))),
    mealItems: List<MealItem>.from(json["mealItems"].map((x) => MealItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "totalCalories": totalCalories,
    "imageUrl": imageUrl,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "mealItems": List<dynamic>.from(mealItems.map((x) => x.toJson())),
  };
}