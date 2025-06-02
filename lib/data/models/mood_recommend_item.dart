import 'meal.dart';

class MoodRecommendItem {
  int id;
  Meal? meal;

  MoodRecommendItem({
    required this.id,
    required this.meal,
  });

  factory MoodRecommendItem.fromJson(Map<String, dynamic> json) => MoodRecommendItem(
    id: json["id"],
    meal: json["meal"] == null ? null : Meal.fromJson(json["meal"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "meal": meal?.toJson(),
  };
}