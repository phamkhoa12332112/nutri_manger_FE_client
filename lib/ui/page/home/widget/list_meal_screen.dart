import 'package:flutter/material.dart';

import '../../../../data/models/meal_recipe.dart';
import '../../../../data/models/recipe.dart';
import '../../detail_meal/detail_meal_screen.dart';
import 'meal_card.dart';

class MealDetailListScreen extends StatelessWidget {
  final String title;
  final int uid;
  final int mealId;
  final List<Recipe> recipes;
  final void Function(DateTime date) loadMealPlan;
  final List<MealRecipe> fetchedMeals;

  const MealDetailListScreen({
    super.key,
    required this.uid,
    required this.mealId,
    required this.recipes,
    required this.title,
    required this.loadMealPlan,
    required this.fetchedMeals,
  });

  Future<int?> _showChooseMealDialog(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn bữa ăn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  fetchedMeals.map((meal) {
                    return ListTile(
                      title: Text(meal.meal.name),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pop(meal.meal.id); // Trả về mealId
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

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
                  builder:
                      (_) => MealDetailScreen(
                        uid: uid,
                        mealId: mealId,
                        recipeId: recipe.id,
                      ),
                ),
              );
            },
            child: MealCard(
              dish: recipe.name,
              recipeId: recipe.id,
              userId: uid,
              loadMealPlan: loadMealPlan,
              onChooseMeal: _showChooseMealDialog, // gọi dialog đã có sẵn
            ),
          );
        },
      ),
    );
  }
}
