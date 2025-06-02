class Meal {
  int id;
  String name;

  Meal({
    required this.id,
    required this.name,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}