class Recipe {
  int id;
  String name;
  String description;
  double totalCalories;
  String imageUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCalories,
    required this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    totalCalories: (json["totalCalories"] as num).toDouble(),
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "totalCalories": totalCalories,
    "imageUrl": imageUrl,
  };
}
