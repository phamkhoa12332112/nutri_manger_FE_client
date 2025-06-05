import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/models/mood_recipe.dart';

import '../../../../data/repository/meal_plan_repository.dart';
import '../../../../utils/app_navigator.dart';
import '../../detail_meal/detail_meal_screen.dart';

class MoodSuggestionsCarousel extends StatelessWidget {
  final List<MoodRecipe> moodBasedSuggestions;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;
  final Function() reloadMealPlan;
  final dynamic user;
  final int mealId;

  const MoodSuggestionsCarousel({
    super.key,
    required this.moodBasedSuggestions,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.reloadMealPlan,
    required this.user,
    required this.mealId,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Center(
            child: Text(
              "Mood Based Suggestions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 320,
            child: Column(
              children: [
                Expanded(
                  child: moodBasedSuggestions.isEmpty
                      ? const Center(
                    child: Text(
                      'No suggestions available for this mood',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : PageView.builder(
                    controller: controller,
                    itemCount: moodBasedSuggestions.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final recipe = moodBasedSuggestions[index].recipe;
                      final double angle = (controller.position.haveDimensions
                          ? index - (controller.page ?? 0)
                          : index - 1) *
                          5;
                      final clampedAngle = angle.clamp(-5, 5);

                      return GestureDetector(
                        onTap: () {
                          AppNavigator.push(
                            context,
                            MealDetailScreen(
                              uid: user.id,
                              mealId: recipe.moodRecommendItems.first.meal!.id,
                              recipeId: recipe.id,
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Transform.rotate(
                                  angle: clampedAngle * pi / 90,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/1200px-Good_Food_Display_-_NCI_Visuals_Online.jpg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        try {


                                          final success = await MealPlanRepositoryImp.instance.createMealPlan(
                                            uid: user.id,
                                            mealId: mealId,
                                            recipeId: recipe.id,
                                            mealTime: DateTime.now(),
                                          );

                                          final snackBar = SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Thêm vào kế hoạch bữa ăn thành công!'
                                                  : 'Thêm vào kế hoạch thất bại.',
                                            ),
                                            backgroundColor: success ? Colors.green : Colors.red,
                                            duration: Duration(seconds: 2),
                                          );

                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          reloadMealPlan();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Có lỗi xảy ra: $e'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              recipe.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
