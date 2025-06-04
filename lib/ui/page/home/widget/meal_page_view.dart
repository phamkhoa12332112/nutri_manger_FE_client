import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/models/user.dart';

import '../../../../data/models/meal_recipe.dart';
import '../../../../utils/sizes_manager.dart';
import '../../detail_meal/detail_meal_screen.dart';
import 'list_meal_screen.dart';
import 'meal_card.dart';

class MealPageView extends StatelessWidget {
  final List<MealRecipe> fetchedMeals;
  final PageController pageController;
  final int selectedIndex;
  final Function(int) onPageChanged;
  final UserDTB user;
  final DateTime selectedDate;
  final Function(DateTime) loadMealPlan;

  const MealPageView({
    super.key,
    required this.fetchedMeals,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.user,
    required this.selectedDate,
    required this.loadMealPlan,
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
              children: fetchedMeals.map((meal) {
                return ListTile(
                  title: Text(meal.meal.name),
                  onTap: () {
                    Navigator.of(context).pop(meal.meal.id); // Trả về mealId
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
    return SizedBox(
      height: HeightSizes.h500,
      child: fetchedMeals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
        controller: pageController,
        itemCount: fetchedMeals.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, mealIndex) {
          final meal = fetchedMeals[mealIndex];
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: meal.recipe.length > 3 ? 4 : meal.recipe.length,
            itemBuilder: (context, index) {
              if (meal.recipe.length > 3 && index == 3) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealDetailListScreen(
                          fetchedMeals: fetchedMeals,
                          loadMealPlan: (date) => loadMealPlan(selectedDate),
                          title: meal.meal.name,
                          uid: user.id,
                          mealId: meal.meal.id,
                          recipes: meal.recipe,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final recipe = meal.recipe[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(
                        uid: user.id,
                        mealId: meal.meal.id,
                        recipeId: recipe.id,
                      ),
                    ),
                  );
                },
                child: MealCard(
                  loadMealPlan: (date) => loadMealPlan(selectedDate),
                  dish: recipe.name,
                  userId: user.id,
                  recipeId: recipe.id,
                  onChooseMeal: _showChooseMealDialog, // gọi dialog đã có sẵn
                ),
              );
            },
          );
        },
      ),
    );
  }
}
