import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/models/meal.dart';

import '../../../../data/models/meal_recipe.dart';
import '../../../../data/models/recipe.dart';
import '../../detail_meal/detail_meal_screen.dart';
import 'meal_card.dart';

class SearchResultScreen extends StatelessWidget {
  final String keyword;
  final Map<Meal, List<Recipe>> categorizedResults;
  final int uid;
  final void Function(DateTime date) loadMealPlan;
  final List<MealRecipe> fetchedMeals;

  const SearchResultScreen({
    super.key,
    required this.keyword,
    required this.categorizedResults,
    required this.uid,
    required this.loadMealPlan,
    required this.fetchedMeals,
  });




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text('Kết quả cho "$keyword"')),
      body: categorizedResults.isEmpty
          ? Center(child: Text('Không tìm thấy món ăn nào'))
          : ListView(
        children: categorizedResults.entries.map((entry) {
          final meal = entry.key;
          final recipes = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  meal.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailScreen(
                            uid: uid,
                            mealId: meal.id,
                            recipeId: recipe.id,
                          ),
                        ),
                      );
                    },
                    child: MealCard(
                      loadMealPlan: loadMealPlan,
                      dish: recipe.name,
                      userId: uid,
                      recipeId: recipe.id,
                      imageUrl: recipe.imageUrl,
                      mealId: meal.id,),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
