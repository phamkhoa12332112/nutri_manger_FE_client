import 'package:flutter/material.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

class IngredientProgress extends StatelessWidget {
  final String ingredient;
  final double totalAmount;
  final Color progressColor;
  final double width;

  const IngredientProgress({
    super.key,
    required this.ingredient,
    required this.totalAmount,
    required this.progressColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          ingredient.toUpperCase(),
          style: TextStyle(
            fontSize: TextSizes.s14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            Container(
              height: HeightSizes.h10,
              width: width,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            GapsManager.w10,
            Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              '${totalAmount}g',
            ),
          ],
        ),
      ],
    );
  }
}
