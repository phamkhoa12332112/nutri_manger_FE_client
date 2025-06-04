
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/models/ingredient_recipe.dart';
import 'package:nutrients_manager/data/models/meal.dart';
import 'package:nutrients_manager/data/models/mood_recipe.dart';
import 'package:nutrients_manager/data/models/nutrient_totals.dart';
import 'package:nutrients_manager/data/repository/detail_meal_repository.dart';
import 'package:nutrients_manager/data/repository/mood_repository.dart';
import 'package:nutrients_manager/ui/page/home/widget/custom_bottom_app_bar.dart';
import 'package:nutrients_manager/ui/page/home/widget/meal_page_view.dart';
import 'package:nutrients_manager/ui/page/home/widget/meal_selector.dart';
import 'package:nutrients_manager/ui/page/home/widget/mood_suggestion_carousel.dart';
import 'package:nutrients_manager/ui/page/home/widget/overview_header.dart';
import 'package:nutrients_manager/ui/page/home/widget/search_screen.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

import '../../../data/models/meal_plan.dart';
import '../../../data/models/meal_recipe.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/user.dart';
import '../../../data/repository/meal_plan_repository.dart';
import '../../../data/repository/meal_repository.dart';
import '../../../data/repository/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  late PageController controller;
  final PageController _pageController = PageController();
  late ScrollController _scrollController;
  late DateTime? selectedDate;
  String selectedMood = 'Happy';
  UserDTB? user;

  double pageoffSet = 1;
  int currentIndex = 1;
  bool isLoading = true;
  int selectedIndex = 0;
  double caloriesGoal = 0;
  double progress = 0.0;

  List<String> moods = [];
  List<String> meals = [];
  late List<MoodRecipe> moodBasedSuggestions = [];
  List<MealPlan> mealPlans = [];
  List<MealRecipe> fetchedMeals = [];

  NutrientTotals? totals;

  final Map<String, String> moodIcons = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😡',
    'Relaxed': '😗',
    'Excited': '😋',
    'Tired': '😴',
    'Stressed': '😣',
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime tenDaysAgo = today.subtract(Duration(days: 10));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: tenDaysAgo,
      lastDate: today,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      loadMealPlan(picked);
    }
  }

  @override
  void initState() {
    super.initState();

    loadMeals();
    loadUserData();
    loadMoods();

    controller = PageController(initialPage: 1, viewportFraction: 0.6)
      ..addListener(() {
        setState(() {
          pageoffSet = controller.page!;
        });
      });
    selectedDate = DateTime.now();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
  }

  Future<IngredientRecipe> loadListIngredients(
    int mealId,
    int recipeId,
    int userId,
  ) async {
    try {
      final ingredients = await DetailMealRepositoryImp.instance
          .fetchDetailMeal(mealId, recipeId, userId);
      return ingredients;
    } catch (e) {
      throw Exception('Failed to load ingredients: $e');
    }
  }

  void loadMealPlan(DateTime date) async {
    if (user == null) return;

    try {
      final mealPlans = await MealPlanRepositoryImp.instance.fetchMealPlan(
        uid: user!.id,
        date: date,
      );

      if (mealPlans.isEmpty) {
        print("No meal plans for today.");
        setState(() {
          this.mealPlans = [];
          totals = NutrientTotals.zero();
          progress = 0.0;
        });
        return;
      }

      NutrientTotals result = NutrientTotals.zero();
      for (final plan in mealPlans) {
        final ingredientRecipe = await loadListIngredients(
          plan.mealItem.meal.id,
          plan.mealItem.recipe.id,
          user!.id,
        );
        final partial = calculateTotalNutrients(ingredientRecipe);

        result = NutrientTotals(
          protein: result.protein + partial.protein,
          carbs: result.carbs + partial.carbs,
          fat: result.fat + partial.fat,
          fiber: result.fiber + partial.fiber,
        );
      }

      setState(() {
        totals = result;
        this.mealPlans = mealPlans;
        progress = calculateCaloriesProgress(
          mealPlans: mealPlans,
          dailyCaloriesGoal: (user!.dailyCaloriesGoal ?? 2000).toDouble(),
        );
        caloriesGoal = calculateCaloriesLeft(
          mealPlans: mealPlans,
          dailyCaloriesGoal: (user!.dailyCaloriesGoal ?? 2000).toDouble(),
        );
      });
    } catch (e) {
      print('Error fetching meal plans: $e');
    }
  }

  void loadMeals() async {
    try {
      final mealsData =
          await MealRepositoryImpl.instance.fetchAllMealsWithRecipes();
      setState(() {
        fetchedMeals = mealsData;
        meals = mealsData.map((e) => e.meal.name).toList();
      });
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  void loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final fetchedUser = await UserRepositoryImpl.instance.fetchUserById(uid);
      if (mounted) {
        setState(() {
          user = fetchedUser;
          caloriesGoal = user!.dailyCaloriesGoal?.toDouble() ?? 0;
          loadMealPlan(selectedDate!);
          isLoading = false; // chỉ tắt loading khi user đã load xong
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // vẫn tắt loading để không kẹt màn hình
        });
      }
    }
  }

  void loadMoods() async {
    try {
      final fetchedMood = await MoodRepositoryImp.instance.fetchAllMoods();
      setState(() {
        moods = fetchedMood.map((mood) => mood.moodName).toList();
        selectedMood = moods.isNotEmpty ? moods[0] : '';
      });
      loadMoodBasedSuggestions(moods.indexOf(selectedMood) + 1);
    } catch (e) {
      print('Error fetching mood: $e');
    }
  }

  void loadMoodBasedSuggestions(int moodId) async {
    if (selectedMood.isEmpty) return;
    try {
      final fetchedSuggestions = await MoodRepositoryImp.instance
          .fetchMoodRecipes(moodId);
      setState(() {
        moodBasedSuggestions = fetchedSuggestions;
      });
      if (controller.hasClients && fetchedSuggestions.isNotEmpty) {
        controller.jumpToPage(0);
      }
    } catch (e) {
      print('Error fetching mood-based suggestions: $e');
    }
  }

  void _performSearch(String value) {
    final keyword = value.toLowerCase().trim();
    if (keyword.isEmpty) return;

    final Map<Meal, List<Recipe>> categorizedResults = {};

    for (final meal in fetchedMeals) {
      for (final recipe in meal.recipe) {
        if (recipe.name.toLowerCase().contains(keyword)) {
          categorizedResults.putIfAbsent(meal.meal, () => []);
          categorizedResults[meal.meal]!.add(recipe);
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SearchResultScreen(
              fetchedMeals: fetchedMeals,
              loadMealPlan: (date) => loadMealPlan(selectedDate!),
              keyword: value,
              categorizedResults: categorizedResults,
              uid: user!.id,
            ),
      ),
    );
  }

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

  double calculateCaloriesProgress({
    required List<MealPlan> mealPlans,
    required double dailyCaloriesGoal,
  }) {
    double totalCalories = 0;

    for (var plan in mealPlans) {
      final mealItem = plan.mealItem;
      final quantity = mealItem.quantity;
      final recipe = mealItem.recipe;
      totalCalories += recipe.totalCalories * quantity;
    }

    return (totalCalories / dailyCaloriesGoal).clamp(0.0, 1.0);
  }

  double calculateCaloriesLeft({
    required List<MealPlan> mealPlans,
    required double dailyCaloriesGoal,
  }) {
    for (var plan in mealPlans) {
      final mealItem = plan.mealItem;
      final quantity = mealItem.quantity;
      final recipe = mealItem.recipe;
      dailyCaloriesGoal -= recipe.totalCalories * quantity;
    }

    return dailyCaloriesGoal;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (isLoading || user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1, uid: user!.id),
      body: Stack(
        children: [
          UserOverviewHeader(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            selectedDate: selectedDate!,
            onSelectDate: _selectDate,
            user: user!,
            selectedMood: selectedMood,
            moods: moods,
            moodIcons: moodIcons,
            caloriesGoal: caloriesGoal,
            progress: progress,
            totals: totals,
            onMoodChanged: (moodId) {
              setState(() {
                selectedMood = moods[moodId - 1];
                currentIndex = 0;
                pageoffSet = 0;
              });
              loadMoodBasedSuggestions(moodId);
            },
          ),

          Positioned(
            top: height * 0.4,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: PaddingSizes.p24,
                      vertical: PaddingSizes.p12,
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      // Hiển thị nút tìm kiếm trên bàn phím
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm món ăn...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusSizes.r16),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: PaddingSizes.p12,
                        ),
                      ),
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      onSubmitted: (value) {
                        _performSearch(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          MoodSuggestionsCarousel(

                            moodBasedSuggestions: moodBasedSuggestions,
                            controller: controller,
                            currentIndex: currentIndex,
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index % moodBasedSuggestions.length;
                              });
                            },
                            reloadMealPlan: () => loadMealPlan(selectedDate!),
                            user: user!, onChooseMeal: _showChooseMealDialog,
                          ),
                          MealSelector(
                            meals: meals,
                            selectedIndex: selectedIndex,
                            pageController: _pageController,
                            onSelect: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),
                          GapsManager.h20,
                          MealPageView(
                            fetchedMeals: fetchedMeals,
                            pageController: _pageController,
                            selectedIndex: selectedIndex,
                            onPageChanged: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            user: user!,
                            selectedDate: selectedDate!,
                            loadMealPlan: loadMealPlan,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
