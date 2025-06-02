import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/models/ingredient_recipe.dart';
import 'package:nutrients_manager/data/models/recipe.dart';
import 'package:nutrients_manager/data/repository/detail_meal_repository.dart';
import 'package:nutrients_manager/data/repository/ingredient_repository.dart';
import 'package:nutrients_manager/data/repository/recipe_repository.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

class MealDetailScreen extends StatefulWidget {
  final int mealId;
  final int recipeId;
  final int uid;

  const MealDetailScreen({
    super.key,
    required this.uid,
    required this.mealId,
    required this.recipeId,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late IngredientRecipe ingredientRecipe;
  late Recipe recipe;
  bool isLoading = true;

  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> calorieControllers = [];
  List<TextEditingController> proteinControllers = [];
  List<TextEditingController> fatControllers = [];
  List<TextEditingController> carbsControllers = [];
  List<TextEditingController> fiberControllers = [];


  @override
  void initState() {
    loadDetailMeal();

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Giải phóng các controller khi không còn sử dụng
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in calorieControllers) {
      controller.dispose();
    }
    for (var controller in proteinControllers) {
      controller.dispose();
    }
    for (var controller in fatControllers) {
      controller.dispose();
    }
    for (var controller in carbsControllers) {
      controller.dispose();
    }
    for (var controller in fiberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> loadDetailMeal() async {
    final fetchedDetailMeal = await DetailMealRepositoryImp.instance
        .fetchDetailMeal(widget.mealId, widget.recipeId, widget.uid);
    final fetchedRecipe = await RecipeRepositoryImp.instance.fetchRecipe(
      widget.recipeId,
    );

    setState(() {
      ingredientRecipe = fetchedDetailMeal;
      recipe = fetchedRecipe;

      // Khởi tạo lại controller mỗi lần load dữ liệu mới
      quantityControllers = [];
      calorieControllers = [];
      proteinControllers = [];
      fatControllers = [];
      carbsControllers = [];
      fiberControllers = [];

      for (final ingredient in ingredientRecipe.ingredients) {
        quantityControllers.add(TextEditingController(
            text: ingredient.recipeItems.first.quantity.toString()));
        calorieControllers
            .add(TextEditingController(text: ingredient.calories.toString()));
        proteinControllers
            .add(TextEditingController(text: ingredient.protein.toString()));
        fatControllers
            .add(TextEditingController(text: ingredient.fat.toString()));
        carbsControllers
            .add(TextEditingController(text: ingredient.carbs.toString()));
        fiberControllers
            .add(TextEditingController(text: ingredient.fiber.toString()));
      }
    });
  }


  Future<void> updateIngredientInformation({
    required int uid,
    required int ingredientId,
    required int recipeId,
    required int quantity,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double fiber,
  }) async {
    await IngredientRepositoryImpl.instance.patchIngredientInformation(
      uid: uid,
      ingredientId: ingredientId,
      recipeId: recipeId,
      quantity: quantity,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      fiber: fiber,
    );
  }

  void _showEditIngredientsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Chỉnh sửa nguyên liệu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...List.generate(ingredientRecipe.ingredients.length, (index) {
                    final ingredient = ingredientRecipe.ingredients[index];
                    final quantityController = quantityControllers[index];
                    final caloriesController = calorieControllers[index];
                    final proteinController = proteinControllers[index];
                    final fatController = fatControllers[index];
                    final carbsController = carbsControllers[index];
                    final fiberController = fiberControllers[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage("assets/images/profile.png"),
                                radius: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredient.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              _buildNutrientField("Qty (${ingredient.unit})", quantityController),
                              _buildNutrientField("Pro", proteinController),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              _buildNutrientField("Fat", fatController),
                              _buildNutrientField("Carbs", carbsController),
                              _buildNutrientField("Fiber", fiberController),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool hasError = false;
                        String errorMessage = '';

                        for (int i = 0; i < ingredientRecipe.ingredients.length; i++) {
                          final quantityText = quantityControllers[i].text;
                          final caloriesText = calorieControllers[i].text;
                          final proteinText = proteinControllers[i].text;
                          final fatText = fatControllers[i].text;
                          final carbsText = carbsControllers[i].text;
                          final fiberText = fiberControllers[i].text;

                          if (quantityText.isEmpty ||
                              caloriesText.isEmpty ||
                              proteinText.isEmpty ||
                              fatText.isEmpty ||
                              carbsText.isEmpty ||
                              fiberText.isEmpty) {
                            hasError = true;
                            errorMessage = 'Vui lòng nhập đầy đủ thông tin cho tất cả nguyên liệu.';
                            break;
                          }

                          if (int.tryParse(quantityText) == null ||
                              double.tryParse(caloriesText) == null ||
                              double.tryParse(proteinText) == null ||
                              double.tryParse(fatText) == null ||
                              double.tryParse(carbsText) == null ||
                              double.tryParse(fiberText) == null) {
                            hasError = true;
                            errorMessage = 'Giá trị nhập vào phải là số hợp lệ.';
                            break;
                          }
                        }

                        if (hasError) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Lỗi nhập liệu'),
                              content: Text(errorMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                )
                              ],
                            ),
                          );
                          return;
                        }

                        try {
                          for (int i = 0; i < ingredientRecipe.ingredients.length; i++) {
                            final ingredient = ingredientRecipe.ingredients[i];

                            final protein = double.parse(proteinControllers[i].text);
                            final fat = double.parse(fatControllers[i].text);
                            final carbs = double.parse(carbsControllers[i].text);
                            final fiber = double.parse(fiberControllers[i].text);
                            final quantity = int.parse(quantityControllers[i].text);

                            double calories = (protein * 4) + (carbs * 4) + (fat * 9);

                            await updateIngredientInformation(
                              uid: widget.uid,
                              ingredientId: ingredient.id,
                              recipeId: recipe.id,
                              quantity: quantity,
                              calories: calories,
                              protein: protein,
                              fat: fat,
                              carbs: carbs,
                              fiber: fiber,
                            );
                          }

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lưu thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            await loadDetailMeal();
                            setState(() {});
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lưu thất bại. Vui lòng thử lại!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

                      child: Text(
                        "Lưu thay đổi",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Đóng",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNutrientField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    snap: true,
                    floating: true,
                    backgroundColor: Color(0xFF200087),
                    expandedHeight: 300,
                    iconTheme: IconThemeData(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(40),
                        ),
                        child: Image.asset(
                          "assets/images/profile.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(PaddingSizes.p8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GapsManager.h20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ingredientRecipe.mealRecipe.meal.name
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: TextSizes.s14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                                Text(
                                  "${recipe.totalCalories} kcal",
                                  style: TextStyle(fontSize: TextSizes.s14),
                                ),
                              ],
                            ),
                            GapsManager.h10,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                recipe.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: TextSizes.s24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GapsManager.h20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "INGREDIENTS",
                                  style: TextStyle(
                                    fontSize: TextSizes.s16,
                                    color: Colors.black54,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      () => _showEditIngredientsPopup(context),
                                  child: Text(
                                    "Chỉnh sửa",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 3,
                                  ),
                              itemCount:
                                  ingredientRecipe.ingredients.length > 4
                                      ? 4
                                      : ingredientRecipe.ingredients.length,
                              itemBuilder: (context, index) {
                                final ingredient =
                                    ingredientRecipe.ingredients[index];
                                final quantity =
                                    ingredient.recipeItems.first.quantity;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            ingredient.imageUrl,
                                            fit: BoxFit.cover,
                                            height: 36,
                                            width: 36,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ingredient.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "${quantity}g",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (ingredientRecipe.ingredients.length > 4)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Xem thêm...",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            GapsManager.h20,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "DESCRIPTION",
                                style: TextStyle(
                                  fontSize: TextSizes.s16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            GapsManager.h8,
                            SingleChildScrollView(
                              child: Text(
                                recipe.description,
                                style: TextStyle(
                                  fontSize: TextSizes.s18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
    );
  }
}
