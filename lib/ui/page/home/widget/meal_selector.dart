import 'package:flutter/material.dart';

class MealSelector extends StatelessWidget {
  final List<String> meals;
  final int selectedIndex;
  final PageController pageController;
  final Function(int) onSelect;

  const MealSelector({
    super.key,
    required this.meals,
    required this.selectedIndex,
    required this.pageController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(meals.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                onSelect(index);
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  meals[index],
                  style: TextStyle(
                    fontSize: isSelected ? 20 : 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.green : Colors.black45,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
