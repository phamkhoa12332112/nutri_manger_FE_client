// To parse this JSON data, do
//
//     final mealPlan = mealPlanFromJson(jsonString);

import 'dart:convert';

import 'package:nutrients_manager/data/models/meal.dart';
import 'package:nutrients_manager/data/models/recipe.dart';

MealPlan mealPlanFromJson(String str) => MealPlan.fromJson(json.decode(str));

String mealPlanToJson(MealPlan data) => json.encode(data.toJson());

class MealPlan {
  int id;
  DateTime mealTime;
  MealItem mealItem;

  MealPlan({
    required this.id,
    required this.mealTime,
    required this.mealItem,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    id: json["id"],
    mealTime: DateTime.parse(json['mealTime']),
    mealItem: MealItem.fromJson(json["mealItem"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mealTime": mealTime.toIso8601String(),
    "mealItem": mealItem.toJson(),
  };
}

class MealItem {
  int id;
  int quantity;
  Meal meal;
  Recipe recipe;

  MealItem({
    required this.id,
    required this.quantity,
    required this.meal,
    required this.recipe,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    id: json["id"],
    quantity: json["quantity"],
    meal: Meal.fromJson(json["meal"]),
    recipe: Recipe.fromJson(json["recipe"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "meal": meal.toJson(),
    "recipe": recipe.toJson(),
  };
}
