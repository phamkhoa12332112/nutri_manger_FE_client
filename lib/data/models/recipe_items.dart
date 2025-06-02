class RecipeItem {
  int id;
  int quantity;

  RecipeItem({
    required this.id,
    required this.quantity,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) => RecipeItem(
    id: json["id"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
  };
}
