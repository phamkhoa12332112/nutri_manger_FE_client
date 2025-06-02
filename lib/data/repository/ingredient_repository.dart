import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class IngredientRepository {
  Future<void> patchIngredientInformation({
    required int uid,
    required int ingredientId,
    required int recipeId,
    required int quantity,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double fiber,
  });

}

class IngredientRepositoryImpl implements IngredientRepository {
  static final IngredientRepositoryImpl _instance = IngredientRepositoryImpl._internal();
  static IngredientRepositoryImpl get instance => _instance;
  final String baseUrl = 'http://10.0.2.2:3003';

  IngredientRepositoryImpl._internal();

  @override
  Future<void> patchIngredientInformation({
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
    final url = Uri.parse('$baseUrl/meals/user/ingredient/$uid');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': uid,
        'ingredientId': ingredientId,
        'recipeId': recipeId,
        'quantity': quantity,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'fiber': fiber,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient information: ${response.body}');
    }
  }

}
