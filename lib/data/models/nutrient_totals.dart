import 'ingredient_recipe.dart';

class NutrientTotals {
  final double protein;
  final double carbs;
  final double fiber;
  final double fat;

  NutrientTotals({
    required this.protein,
    required this.carbs,
    required this.fiber,
    required this.fat,
  });

  factory NutrientTotals.zero() {
    return NutrientTotals(protein: 0, carbs: 0, fat: 0, fiber: 0);
  }
}

NutrientTotals calculateTotalNutrients(IngredientRecipe ingredientRecipe) {
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFiber = 0;
  double totalFat = 0;

  for (var ingredient in ingredientRecipe.ingredients) {
    final quantity = ingredient.recipeItems.first.quantity;

    totalFat += (ingredient.fat ?? 0) * quantity;
    totalProtein += (ingredient.protein ?? 0) * quantity;
    totalCarbs += (ingredient.carbs ?? 0) * quantity;
    totalFiber += (ingredient.fiber ?? 0) * quantity;
  }

  return NutrientTotals(
    fat: totalFat,
    protein: totalProtein,
    carbs: totalCarbs,
    fiber: totalFiber,
  );
}
