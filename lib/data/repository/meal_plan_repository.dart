import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/meal_plan.dart';

import '../models/user.dart';

abstract class MealPlanRepository {
  Future<bool> createMealPlan({
    required int uid,
    required int mealId,
    required int recipeId,
    required DateTime mealTime,
  });

  Future<List<MealPlan>> fetchMealPlan({required int uid, required DateTime date});

  Future<bool> deleteMealPlan({required int uid, required int detailMealId});
}

class MealPlanRepositoryImp implements MealPlanRepository {
  static final MealPlanRepositoryImp _instance =
      MealPlanRepositoryImp._internal();

  static MealPlanRepositoryImp get instance => _instance;
  final String baseUrl = 'http://10.0.2.2:3003';

  MealPlanRepositoryImp._internal();

  @override
  Future<bool> createMealPlan({
    required int uid,
    required int mealId,
    required int recipeId,
    required DateTime mealTime,
  }) async {
    final url = Uri.parse('$baseUrl/meals/user/create/$uid');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "mealId": mealId,
        "recipeId": recipeId,
        "mealTime": mealTime.toIso8601String(),
      }),
    );
    final result = jsonDecode(response.body);

    return result['stateCode'] == 200;
  }

  @override
  Future<List<MealPlan>> fetchMealPlan({required int uid, required DateTime date}) async {
    final url = Uri.parse('$baseUrl/meals/user/details/$uid?date=${date.toIso8601String()}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> rawList = data['data'];
      return rawList.map((e) => MealPlan.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load meal plans: ${response.statusCode}");
    }
  }

  @override
  Future<bool> deleteMealPlan({
    required int uid,
    required int detailMealId,
  }) async {
    final url = Uri.parse('$baseUrl/meals/user/delete/$uid/$detailMealId');
    final response = await http.delete(url);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete meal plan: ${response.body}');
    }
    return response.statusCode == 200;
  }
}
