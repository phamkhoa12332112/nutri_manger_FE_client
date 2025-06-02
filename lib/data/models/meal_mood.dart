import 'package:nutrients_manager/data/models/recipe.dart';

import 'mood_recommend_item.dart';

class MealMood extends Recipe {
  List<MoodRecommendItem> moodRecommendItems;

  MealMood({
    required super.id,
    required super.name,
    required super.description,
    required super.totalCalories,
    required super.imageUrl,
    required this.moodRecommendItems,
  });

  factory MealMood.fromJson(Map<String, dynamic> json) =>
      MealMood(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        totalCalories: (json["totalCalories"] as num).toDouble(),
        imageUrl: json["imageUrl"],
        moodRecommendItems: List<MoodRecommendItem>.from(
          json["moodRecommendItems"].map((x) => MoodRecommendItem.fromJson(x)),
        ),
      );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "moodRecommendItems":
    List<dynamic>.from(moodRecommendItems.map((x) => x.toJson())),
  };
}
