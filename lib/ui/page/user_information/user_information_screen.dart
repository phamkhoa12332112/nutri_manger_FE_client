import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nutrients_manager/ui/page/home/home_screen.dart';
import 'package:nutrients_manager/ui/page/user_information/widget/bmi_goal_dialog.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repository/user_repository.dart';
import '../../../utils/sizes_manager.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'Nam';
  String _activityLevel = 'Ít vận động';
  late String _uid;

  final _activityFactors = {
    'Ít vận động': 1.2,
    'Vận động nhẹ': 1.375,
    'Vận động vừa': 1.55,
    'Vận động nhiều': 1.725,
    'Vận động rất nặng': 1.9,
  };

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = prefs.getString('user_id') ?? "";
    });
  }

  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  void _calculate() async {
    if (_formKey.currentState?.validate() != true) return;

    final double weight = double.parse(_weightController.text);
    final double heightCm = double.parse(_heightController.text);

    final int age = int.parse(_ageController.text);
    final double heightM = heightCm / 100;

    final double bmi = weight / (heightM * heightM);
    final double minIdeal = 18.5 * heightM * heightM;
    final double maxIdeal = 24.9 * heightM * heightM;

    final String bmiStatus = _getBmiStatus(bmi);

    double bmr;
    if (_gender == 'Nam') {
      bmr = 10 * weight + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * heightCm - 5 * age - 161;
    }

    final double tdee = bmr * (_activityFactors[_activityLevel] ?? 1.2);
    double weightGoal = weight;

    final selectedOption = await BmiGoalDialog.showBmiChoiceDialog(
      context,
      bmi,
      minIdeal,
      maxIdeal,
    );

    if (selectedOption == null) return;

    if (selectedOption == 'BMI') {
      weightGoal = ((minIdeal + maxIdeal) / 2);
    } else {
      final customWeight = await BmiGoalDialog.showCustomWeightDialog(context);
      if (customWeight != null && customWeight > 0) {
        weightGoal = customWeight;
      } else {
        return;
      }
    }
    final repo = UserRepositoryImpl.instance;

    await repo.patchUserInformation(
      uid: _uid,
      name: _nameController.text,
      weight: weight,
      height: heightCm,
      age: age,
      gender:  _gender == 'Nam',
      level: _activityFactors[_activityLevel]!,
      dailyCaloriesGoal: tdee,
      weightGoal: weightGoal.roundToDouble(),
    );

    AppNavigator.push(context, const HomeScreen());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA0C878),
        title: Text(
          'Tính BMI & TDEE',
          style: TextStyle(fontSize: TextSizes.s24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
                  if (value.trim().length < 2) return 'Tên quá ngắn';
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập cân nặng';
                  final num? val = num.tryParse(value);
                  if (val == null || val <= 0) return 'Cân nặng không hợp lệ';
                  return null;
                },
              ),
              GapsManager.h20,
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập chiều cao';
                  final num? val = num.tryParse(value);
                  if (val == null || val <= 0) return 'Chiều cao không hợp lệ';
                  return null;
                },
              ),
              GapsManager.h20,
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tuổi'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập tuổi';
                  final num? val = num.tryParse(value);
                  if (val == null || val <= 0) return 'Tuổi không hợp lệ';
                  return null;
                },
              ),
              GapsManager.h20,
              DropdownButtonFormField<String>(
                value: _gender,
                onChanged: (value) => setState(() => _gender = value!),
                items:
                    ['Nam', 'Nữ']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                decoration: const InputDecoration(labelText: 'Giới tính'),
              ),
              GapsManager.h20,
              DropdownButtonFormField<String>(
                value: _activityLevel,
                onChanged: (value) => setState(() => _activityLevel = value!),
                items:
                    _activityFactors.keys
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                decoration: const InputDecoration(labelText: 'Mức độ vận động'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFFFDF6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: TextSizes.s16),
            backgroundColor: const Color(0xFFA0C878),
          ),
          onPressed: _calculate,
          child: Text(
            'Tiếp tục',
            style: TextStyle(fontSize: TextSizes.s20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
