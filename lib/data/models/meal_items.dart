import 'meal.dart';

class MealItem {
  int id;
  int quantity;
  Meal meal;

  MealItem({
    required this.id,
    required this.quantity,
    required this.meal,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    id: json["id"],
    quantity: json["quantity"],
    meal: Meal.fromJson(json["meal"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "meal": meal.toJson(),
  };
}