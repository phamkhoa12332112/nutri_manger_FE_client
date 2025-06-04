import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrients_manager/ui/page/home/widget/radio_progress.dart';

import '../../../../data/models/nutrient_totals.dart';
import '../../../../data/models/user.dart';
import 'ingredient_progress.dart';

class UserOverviewHeader extends StatefulWidget {
  final double height;
  final double width;
  final DateTime selectedDate;
  final void Function(BuildContext context) onSelectDate;
  final UserDTB user;
  final String selectedMood;
  final List<String> moods;
  final Map<String, String> moodIcons;
  final double caloriesGoal;
  final double progress;
  final NutrientTotals? totals;
  final void Function(int moodId) onMoodChanged;

  const UserOverviewHeader({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedDate,
    required this.onSelectDate,
    required this.user,
    required this.selectedMood,
    required this.moods,
    required this.moodIcons,
    required this.caloriesGoal,
    required this.progress,
    required this.totals,
    required this.onMoodChanged,
  }) : super(key: key);

  @override
  State<UserOverviewHeader> createState() => _UserOverviewHeaderState();
}

class _UserOverviewHeaderState extends State<UserOverviewHeader> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      height: widget.height * 0.38,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        child: Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.only(
            top: 40,
            left: 32,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            children: [
              ListTile(
                title: GestureDetector(
                  onTap: () => widget.onSelectDate(context),
                  child: Row(
                    children: [
                      Text(
                        "${DateFormat("EEEE").format(widget.selectedDate)}, ${DateFormat("d MMMM").format(widget.selectedDate)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.calendar_month_outlined),
                    ],
                  ),
                ),
                subtitle: Text(
                  'Hello, ${widget.user.name}!',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: widget.selectedMood,
                      underline: const SizedBox(),
                      items: widget.moods.map((String mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(
                            widget.moodIcons[mood] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newMood) {
                        if (newMood != null) {
                          final moodId = widget.moods.indexOf(newMood) + 1;
                          widget.onMoodChanged(moodId);
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: Text(
                        (widget.user.name?[0] ?? "k").toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  RadioProgress(
                    number: widget.caloriesGoal,
                    height: widget.height * 0.2,
                    width: widget.width * 0.35,
                    progress: widget.progress,
                  ),
                  const SizedBox(width: 15),
                  widget.totals == null
                      ? const CircularProgressIndicator()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IngredientProgress(
                        ingredient: "Protein",
                        totalAmount: widget.totals!.protein.toDouble(),
                        progressColor: Colors.purple,
                        width: widget.width * 0.3,
                      ),
                      IngredientProgress(
                        ingredient: "Carbs",
                        totalAmount: widget.totals!.carbs.toDouble(),
                        width: widget.width * 0.3,
                        progressColor: Colors.red,
                      ),
                      IngredientProgress(
                        ingredient: "Fat",
                        totalAmount: widget.totals!.fat.toDouble(),
                        width: widget.width * 0.3,
                        progressColor: Colors.green,
                      ),
                      IngredientProgress(
                        ingredient: "Fiber",
                        totalAmount: widget.totals!.fiber.toDouble(),
                        width: widget.width * 0.3,
                        progressColor: Colors.yellow,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

