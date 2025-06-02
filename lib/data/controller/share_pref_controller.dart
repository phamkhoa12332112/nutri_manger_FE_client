import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsController {
  static final SharedPrefsController _instance = SharedPrefsController._internal();

  factory SharedPrefsController() => _instance;

  late final SharedPreferences prefs;

  SharedPrefsController._internal();

  static SharedPrefsController getInstance() => _instance;

  /// Gọi hàm này trong init (main hoặc splash) để khởi tạo
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Example methods
  Future<void> setUserId(String userId) async {
    await prefs.setString('user_id', userId);
  }

  String getUserId() {
    return prefs.getString('user_id') ?? '';
  }

  Future<void> clear() async {
    await prefs.clear();
  }
}