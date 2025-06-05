import 'package:flutter/material.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

import '../../../../data/repository/meal_plan_repository.dart';
import '../../../../utils/gaps_manager.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.dish,
    required this.recipeId, required this.userId, required this.loadMealPlan,
    required this.mealId,
  });

  final String dish;
  final int userId;
  final int recipeId;
  final int mealId;
  final void Function(DateTime date) loadMealPlan;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MarginSizes.m16),
            height: HeightSizes.h280,
            width: WidthSizes.w180,
            child: Stack(
              children: [
                // Ảnh nền
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/1200px-Good_Food_Display_-_NCI_Visuals_Online.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(RadiusSizes.r20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
                // Nút dấu +
                Positioned(
                  top: 10,
                  right: 10,
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
                          final success = await MealPlanRepositoryImp.instance
                              .createMealPlan(
                            uid: userId,
                            mealId: mealId,
                            recipeId: recipeId,
                            mealTime: DateTime.now(),
                          );

                          final snackBar = SnackBar(
                            content: Text(success
                                ? 'Thêm vào kế hoạch bữa ăn thành công!'
                                : 'Thêm vào kế hoạch thất bại.'),
                            backgroundColor: success ? Colors.green : Colors
                                .red,
                            duration: Duration(seconds: 2),
                          );

                          // Hiện SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } catch (e) {
                          // Nếu lỗi bất ngờ
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Có lỗi xảy ra: $e'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        loadMealPlan(DateTime.now());
                      },
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
        GapsManager.h20,
        Text(
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          dish,
          style: TextStyle(
            fontSize: TextSizes.s20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
