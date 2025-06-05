import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/models/statistic.dart';

import '../models/user.dart';

abstract class StatisticsRepository {
  Future<List<Statistic>> getStatisticFromDateToDate({
    required int uid,
    required DateTime from,
    required DateTime to,
  });
}

class StatisticsRepositoryImpl implements StatisticsRepository {
  static final StatisticsRepositoryImpl _instance = StatisticsRepositoryImpl._internal();
  static StatisticsRepositoryImpl get instance => _instance;
  final String baseUrl = 'http://10.0.2.2:3003';

  StatisticsRepositoryImpl._internal();


  @override
  Future<List<Statistic>> getStatisticFromDateToDate({
    required int uid,
    required DateTime from,
    required DateTime to,
  }) async {
    print(from);
    final url = Uri.parse('$baseUrl/users/statistics/$uid?from=${from.toIso8601String()}&to=${to.toIso8601String()}');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
      );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> rawList = data['data'];
      print(rawList);
      return rawList.map((e) => Statistic.fromJson(e)).toList();
    } else {
      throw Exception('Failed to get statistic: ${response.body}');
    }
  }

}
