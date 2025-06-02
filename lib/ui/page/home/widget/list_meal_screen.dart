import 'package:flutter/material.dart';

import '../../../../data/models/recipe.dart';
import '../../detail_meal/detail_meal_screen.dart';
import 'meal_card.dart';

class MealDetailListScreen extends StatelessWidget {
  final String title;
  final int uid;
  final int mealId;
  final List<Recipe> recipes;
  final void Function(DateTime date) loadMealPlan;

  const MealDetailListScreen({
    super.key,
    required this.uid,
    required this.mealId,
    required this.recipes, required this.title, required this.loadMealPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealDetailScreen(
                    uid: uid,
                    mealId: mealId,
                    recipeId: recipe.id,
                  ),
                ),
              );
            },
            child: MealCard(
              loadMealPlan: (date) => loadMealPlan(DateTime.now()),
              dish: recipe.name,
              userId: uid,
              mealId: mealId,
              recipeId: recipe.id,
            ),
          );
        },
      ),
    );
  }
}
