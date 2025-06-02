import 'package:flutter/material.dart';
import 'package:nutrients_manager/ui/page/home/home_screen.dart';
import 'package:nutrients_manager/ui/page/meal_plan/meal_plan_screen.dart';
import 'package:nutrients_manager/ui/page/profile/profile_screen.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int uid;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, this.onTap, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      fixedColor: Colors.black,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      iconSize: 40,
      selectedIconTheme: const IconThemeData(color: Colors.black),
      unselectedIconTheme: const IconThemeData(color: Colors.black12),
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          switch (index) {
            case 0:
              AppNavigator.push(context, MealPlanScreen(uid: uid,));
              break;
            case 1:
              AppNavigator.push(context, const HomeScreen());
              break;
            case 2:
              AppNavigator.push(context, const ProfileScreen());
              break;
          }
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.fastfood_outlined),
          ),
          label: 'My Plan',
        ),
        BottomNavigationBarItem(
          icon: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.home)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
