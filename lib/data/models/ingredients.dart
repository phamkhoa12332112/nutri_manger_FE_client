import 'package:nutrients_manager/data/models/recipe_items.dart';

class Ingredient {
  int id;
  String name;
  double calories;
  double protein;
  double fat;
  double carbs;
  double fiber;
  String unit;
  String imageUrl;
  List<RecipeItem> recipeItems;

  Ingredient({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.unit,
    required this.imageUrl,
    required this.recipeItems,

  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json["id"],
    name: json["name"],
    calories: json["calories"]?.toDouble(),
    protein: json["protein"]?.toDouble(),
    fat: json["fat"]?.toDouble(),
    carbs: json["carbs"]?.toDouble(),
    fiber: json["fiber"]?.toDouble(),
    unit: json["unit"],
    imageUrl: json["imageUrl"],
    recipeItems: List<RecipeItem>.from(json["recipeItems"].map((x) => RecipeItem.fromJson(x))),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "calories": calories,
    "protein": protein,
    "fat": fat,
    "carbs": carbs,
    "fiber": fiber,
    "unit": unit,
    "imageUrl": imageUrl,
  };
}