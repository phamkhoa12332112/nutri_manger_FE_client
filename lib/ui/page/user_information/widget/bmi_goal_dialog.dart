import 'package:flutter/material.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';

import '../../../../utils/text_manag.dart';

class BmiGoalDialog {
  static Future<String?> showBmiChoiceDialog(
    BuildContext context,
    double bmi,
    double minIdeal,
    double maxIdeal,
  ) async {
    String status;
    if (bmi < 18.5) {
      status = 'Bạn đang thiếu cân';
    } else if (bmi > 24.9) {
      status = 'Bạn đang thừa cân';
    } else {
      status = 'Bạn có cân nặng lý tưởng';
    }

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI của bạn: ${bmi.toStringAsFixed(2)}',
                  style: TextManager.bmiTitle,
                ),
                GapsManager.h8,
                Text(status, style: TextManager.bmiStatus),
                GapsManager.h16,
                Text('Chọn mục tiêu cân nặng', style: TextManager.hintText),
              ],
            ),
            content: Text(
              'Bạn muốn sử dụng cân nặng theo BMI lý tưởng hay nhập cân nặng mục tiêu của riêng bạn?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'BMI'),
                child: Text(
                  'Theo BMI (${((minIdeal + maxIdeal)/2).toStringAsFixed(1)} kg)',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'Nhập tay'),
                child: const Text('Nhập tay'),
              ),
            ],
          ),
    );
  }

  static Future<double?> showCustomWeightDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nhập cân nặng mục tiêu (kg)'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'VD: 60'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  Navigator.pop(context, value);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
