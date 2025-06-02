import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrients_manager/data/models/ingredient_recipe.dart';
import 'package:nutrients_manager/data/models/meal.dart';
import 'package:nutrients_manager/data/models/meal_mood.dart';
import 'package:nutrients_manager/data/models/mood_recipe.dart';
import 'package:nutrients_manager/data/models/nutrient_totals.dart';
import 'package:nutrients_manager/data/repository/detail_meal_repository.dart';
import 'package:nutrients_manager/data/repository/mood_repository.dart';
import 'package:nutrients_manager/ui/page/home/widget/custom_bottom_app_bar.dart';
import 'package:nutrients_manager/ui/page/home/widget/ingredient_progress.dart';
import 'package:nutrients_manager/ui/page/home/widget/meal_card.dart';
import 'package:nutrients_manager/ui/page/home/widget/radio_progress.dart';
import 'package:nutrients_manager/ui/page/home/widget/search_screen.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

import '../../../data/models/meal_plan.dart';
import '../../../data/models/meal_recipe.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/user.dart';
import '../../../data/repository/meal_plan_repository.dart';
import '../../../data/repository/meal_repository.dart';
import '../../../data/repository/user_repository.dart';
import '../detail_meal/detail_meal_screen.dart';
import 'widget/list_meal_screen.dart';

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
              loadMealPlan: (date) => loadMealPlan(selectedDate!),
              keyword: value,
              categorizedResults: categorizedResults,
              uid: user!.id,
            ),
      ),
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
          Positioned(
            top: 0,
            height: height * 0.38,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Container(
                color: Colors.grey.shade50,
                padding: EdgeInsets.only(
                  top: 40,
                  left: 32,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Text(
                              "${DateFormat("EEEE").format(selectedDate!)}, ${DateFormat("d MMMM").format(selectedDate!)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.calendar_month_outlined),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        'Hello, ${user!.name}!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: selectedMood,
                            underline: SizedBox(),
                            items:
                                moods.map((String mood) {
                                  return DropdownMenuItem<String>(
                                    value: mood,
                                    child: Text(
                                      moodIcons[mood] ?? '',
                                      style: TextStyle(
                                        fontSize: TextSizes.s20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newMood) {
                              if (newMood != null) {
                                setState(() {
                                  selectedMood = newMood;
                                  currentIndex = 0;
                                  pageoffSet = 0;
                                });
                                final moodId = moods.indexOf(newMood) + 1;
                                loadMoodBasedSuggestions(moodId);
                              }
                            },
                          ),
                          SizedBox(width: 10),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/profile.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        RadioProgress(
                          number: caloriesGoal,
                          height: height * 0.2,
                          width: width * 0.35,
                          progress: progress,
                        ),
                        SizedBox(width: 15),
                        totals == null
                            ? CircularProgressIndicator()
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                IngredientProgress(
                                  ingredient: "Protein",
                                  totalAmount: totals!.protein.toDouble(),
                                  progressColor: Colors.purple,
                                  width: width * 0.3,
                                ),
                                IngredientProgress(
                                  ingredient: "Carbs",
                                  totalAmount: totals!.carbs.toDouble(),
                                  width: width * 0.3,
                                  progressColor: Colors.red,
                                ),
                                IngredientProgress(
                                  ingredient: "Fat",
                                  totalAmount: totals!.fat.toDouble(),
                                  width: width * 0.3,
                                  progressColor: Colors.green,
                                ),
                                IngredientProgress(
                                  ingredient: "Fiber",
                                  totalAmount: totals!.fiber.toDouble(),
                                  width: width * 0.3,
                                  progressColor: Colors.yellow,
                                ),
                              ],
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
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
                                SizedBox(height: 10),
                                SizedBox(
                                  height: 320,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child:
                                            moodBasedSuggestions.isEmpty
                                                ? Center(
                                                  child: Text(
                                                    'No suggestions available for this mood',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                )
                                                : PageView.builder(
                                                  onPageChanged: (index) {
                                                    if (moodBasedSuggestions
                                                        .isNotEmpty) {
                                                      setState(() {
                                                        currentIndex =
                                                            index %
                                                            moodBasedSuggestions
                                                                .length;
                                                      });
                                                    }
                                                  },

                                                  controller: controller,
                                                  itemCount:
                                                      moodBasedSuggestions
                                                          .length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    if (moodBasedSuggestions
                                                            .isEmpty ||
                                                        index >=
                                                            moodBasedSuggestions
                                                                .length) {
                                                      return SizedBox();
                                                    }

                                                    MealMood recipe =
                                                        moodBasedSuggestions[index]
                                                            .recipe;

                                                    double angle =
                                                        (controller
                                                                .position
                                                                .haveDimensions
                                                            ? index.toDouble() -
                                                                (controller
                                                                        .page ??
                                                                    0)
                                                            : index.toDouble() -
                                                                1) *
                                                        5;
                                                    angle = angle.clamp(-5, 5);
                                                    return GestureDetector(
                                                      onTap: () {
                                                        AppNavigator.push(
                                                          context,
                                                          MealDetailScreen(
                                                            uid: user!.id,
                                                            mealId:
                                                                recipe
                                                                    .moodRecommendItems
                                                                    .first
                                                                    .meal!
                                                                    .id,
                                                            recipeId: recipe.id,
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Transform.rotate(
                                                                angle:
                                                                    angle *
                                                                    pi /
                                                                    90,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        25,
                                                                      ),
                                                                  child: Image.network(
                                                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/1200px-Good_Food_Display_-_NCI_Visuals_Online.jpg',
                                                                    height: 200,
                                                                    width: 200,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 8,
                                                                right: 8,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color:
                                                                            Colors.black26,
                                                                        blurRadius:
                                                                            4,
                                                                        offset:
                                                                            Offset(
                                                                              2,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: IconButton(
                                                                    icon: Icon(
                                                                      Icons.add,
                                                                    ),
                                                                    onPressed: () async {
                                                                      try {
                                                                        final success = await MealPlanRepositoryImp.instance.createMealPlan(
                                                                          uid:
                                                                              user!.id,
                                                                          mealId:
                                                                              recipe.moodRecommendItems.first.meal!.id,
                                                                          recipeId:
                                                                              recipe.id,
                                                                          mealTime:
                                                                              DateTime.now(),
                                                                        );

                                                                        final snackBar = SnackBar(
                                                                          content: Text(
                                                                            success
                                                                                ? 'Thêm vào kế hoạch bữa ăn thành công!'
                                                                                : 'Thêm vào kế hoạch thất bại.',
                                                                          ),
                                                                          backgroundColor:
                                                                              success
                                                                                  ? Colors.green
                                                                                  : Colors.red,
                                                                          duration: Duration(
                                                                            seconds:
                                                                                2,
                                                                          ),
                                                                        );

                                                                        // Hiện SnackBar
                                                                        ScaffoldMessenger.of(
                                                                          context,
                                                                        ).showSnackBar(
                                                                          snackBar,
                                                                        );
                                                                      } catch (
                                                                        e
                                                                      ) {
                                                                        // Nếu lỗi bất ngờ
                                                                        ScaffoldMessenger.of(
                                                                          context,
                                                                        ).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text(
                                                                              'Có lỗi xảy ra: $e',
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                            duration: Duration(
                                                                              seconds:
                                                                                  2,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      loadMealPlan(
                                                                        selectedDate!,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 12),
                                                          Text(
                                                            recipe.name,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors
                                                                      .black87,
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
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(meals.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });

                                      _scrollController.animateTo(
                                        _scrollController
                                                .position
                                                .maxScrollExtent *
                                            (index / (meals.length - 1)),
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );

                                      _pageController.animateToPage(
                                        index,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        meals[index],
                                        style: TextStyle(
                                          fontSize:
                                              selectedIndex == index ? 20 : 15,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              selectedIndex == index
                                                  ? Colors.green
                                                  : Colors.black45,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          GapsManager.h20,
                          SizedBox(
                            height: HeightSizes.h500,
                            child:
                                fetchedMeals.isEmpty
                                    ? Center(child: CircularProgressIndicator())
                                    : PageView.builder(
                                      controller: _pageController,
                                      itemCount: fetchedMeals.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          selectedIndex = index;
                                        });

                                        _scrollController.animateTo(
                                          _scrollController
                                                  .position
                                                  .maxScrollExtent *
                                              (index / (meals.length - 1)),
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      itemBuilder: (context, mealIndex) {
                                        final meal = fetchedMeals[mealIndex];
                                        return GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                          itemCount:
                                              meal.recipe.length > 3
                                                  ? 4
                                                  : meal.recipe.length,
                                          itemBuilder: (context, index) {
                                            if (meal.recipe.length > 3 &&
                                                index == 3) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => MealDetailListScreen(
                                                            loadMealPlan:
                                                                (
                                                                  date,
                                                                ) => loadMealPlan(
                                                                  selectedDate!,
                                                                ),
                                                            title:
                                                                meal.meal.name,
                                                            uid: user!.id,
                                                            mealId:
                                                                meal.meal.id,
                                                            recipes:
                                                                meal.recipe,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Xem thêm',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    builder:
                                                        (_) => MealDetailScreen(
                                                          uid: user!.id,
                                                          mealId: meal.meal.id,
                                                          recipeId: recipe.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: MealCard(
                                                loadMealPlan:
                                                    (date) => loadMealPlan(
                                                      selectedDate!,
                                                    ),
                                                dish: recipe.name,
                                                userId: user!.id,
                                                mealId: meal.meal.id,
                                                recipeId: recipe.id,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
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
