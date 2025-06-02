import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrients_manager/data/models/meal_plan.dart';
import 'package:nutrients_manager/data/repository/meal_plan_repository.dart';
import 'package:nutrients_manager/ui/page/detail_meal/detail_meal_screen.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';

import '../home/widget/custom_bottom_app_bar.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key, required this.uid});

  final int uid;

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime selectedDate = DateTime.now();
  late List<MealPlan> fetchedMealPlans = [];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        loadMealPlan();
      });
    }
  }

  void loadMealPlan() async {
    try {
      final mealPLanData = await MealPlanRepositoryImp.instance.fetchMealPlan(
        uid: widget.uid,
        date: selectedDate,
      );
      setState(() {
        fetchedMealPlans = mealPLanData;
      });
    } catch (e) {
      print('Error fetching meals plan: $e');
    }
  }

  Map<String, List<Map<String, String>>> groupMealsByMealName(
    List<MealPlan> mealPlans,
  ) {
    final Map<String, List<Map<String, String>>> grouped = {};

    for (var plan in mealPlans) {
      final mealName = plan.mealItem.meal.name;
      final recipe = plan.mealItem.recipe;
      final timeFormatted = DateFormat.Hm().format(plan.mealTime.toLocal());
      final mealData = {
        'id': plan.id.toString(),
        'name': recipe.name,
        'time': timeFormatted,
        'calories': '${recipe.totalCalories} kcal',
        'mealId': plan.mealItem.meal.id.toString(),
        'recipeId': plan.mealItem.recipe.id.toString(),
      };

      if (!grouped.containsKey(mealName)) {
        grouped[mealName] = [];
      }

      grouped[mealName]!.add(mealData);
    }

    return grouped;
  }

  @override
  void initState() {
    loadMealPlan();

    Future.delayed(Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupedMeals = groupMealsByMealName(fetchedMealPlans);
    final dateFormatted = DateFormat('EEEE, MMM d').format(selectedDate);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Meal Plan'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _pickDate),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0, uid: widget.uid),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            dateFormatted,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...groupedMeals.entries.map((entry) {
            return GestureDetector(
              onTap: () {
                AppNavigator.push(
                  context,
                  MealDetailScreen(
                    uid: widget.uid,
                    mealId: int.parse(entry.value.first['mealId']!),
                    recipeId: int.parse(entry.value.first['recipeId']!),
                  ),
                );
              },
              child: MealSection(
                title: entry.key,
                meals: entry.value,
                uid: widget.uid,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MealSection extends StatefulWidget {
  final String title;
  final List<Map<String, String>> meals;
  final int uid;

  const MealSection({
    required this.title,
    required this.meals,
    required this.uid,
    super.key,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {

  void deleteMealPlan(int detailMealId) async {
    try {
      await MealPlanRepositoryImp.instance.deleteMealPlan(
        uid: widget.uid,
        detailMealId: detailMealId,
      );

      setState(() {
        widget.meals.removeWhere(
              (meal) => int.parse(meal['id']!) == detailMealId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xoá món ăn thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error delete meals plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xoá món ăn thất bại!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.green.shade100,
      margin: EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            ...widget.meals.map(
              (meal) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(meal['name']!),
                subtitle: Text('${meal['time']} • ${meal['calories']}'),
                leading: Icon(Icons.restaurant_menu),
                trailing: IconButton(
                  icon: Icon(Icons.minimize),
                  onPressed: () => deleteMealPlan(int.parse(meal['id']!)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
