import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';

abstract class UserRepository {
  Future<void> patchUserInformation({
    required String uid,
    required String name,
    required double height,
    required double weight,
    required int age,
    required bool gender,
    required double level,
    required double dailyCaloriesGoal,
    required double weightGoal,
  });

  Future<bool> createUser({
    required String uid,
    required String email,
  });
}

class UserRepositoryImpl implements UserRepository {
  static final UserRepositoryImpl _instance = UserRepositoryImpl._internal();
  static UserRepositoryImpl get instance => _instance;
  final String baseUrl = 'http://10.0.2.2:3003';

  UserRepositoryImpl._internal();

  @override
  Future<void> patchUserInformation({
    required String uid,
    required String name,
    required double height,
    required double weight,
    required int age,
    required bool gender,
    required double level,
    required double dailyCaloriesGoal,
    required double weightGoal,
  }) async {
    final url = Uri.parse('$baseUrl/users/update');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': uid,
        'name': name,
        'height': height,
        'weight': weight,
        'gender': gender,
        'age': age,
        'dailyCaloriesGoal': dailyCaloriesGoal,
        'levelExercise': level,
        'weightGoal': weightGoal,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user information: ${response.body}');
    }
  }

  Future<UserDTB?> fetchUserById(String uid) async {
    final url = Uri.parse('$baseUrl/users/me/$uid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserDTB.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }


  @override
  Future<bool> createUser({
    required String uid,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': uid,
        'email': email,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user: ${response.body}');
    }
    return response.statusCode == 200;
  }
}
