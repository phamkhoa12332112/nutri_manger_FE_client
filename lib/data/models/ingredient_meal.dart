
class IngredientMeal {
  int id;
  String name;
  double calories;
  double protein;
  double fat;
  double carbs;
  double fiber;
  String unit;
  String imageUrl;

  IngredientMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.unit,
    required this.imageUrl,
  });

  factory IngredientMeal.fromJson(Map<String, dynamic> json) => IngredientMeal(
    id: json["id"],
    name: json["name"],
    calories: json["calories"]?.toDouble(),
    protein: json["protein"]?.toDouble(),
    fat: json["fat"]?.toDouble(),
    carbs: json["carbs"]?.toDouble(),
    fiber: json["fiber"]?.toDouble(),
    unit: json["unit"],
    imageUrl: json["imageUrl"],
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