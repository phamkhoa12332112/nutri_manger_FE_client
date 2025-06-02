import 'package:equatable/equatable.dart';
import 'package:nutrients_manager/data/models/meal_recipe.dart';
import 'package:nutrients_manager/data/models/mood_recipe.dart';
import 'package:nutrients_manager/data/models/user.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final DateTime selectedDate;
  final List<MealRecipe> meals;
  final List<MoodRecipe> moodSuggestions;
  final List<String> moods;
  final String selectedMood;
  final UserDTB? user;

  const HomeState({
    this.isLoading = true,
    required this.selectedDate,
    this.meals = const [],
    this.moodSuggestions = const [],
    this.moods = const [],
    this.selectedMood = '',
    this.user,
  });

  HomeState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    List<MealRecipe>? meals,
    List<MoodRecipe>? moodSuggestions,
    List<String>? moods,
    String? selectedMood,
    UserDTB? user,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      meals: meals ?? this.meals,
      moodSuggestions: moodSuggestions ?? this.moodSuggestions,
      moods: moods ?? this.moods,
      selectedMood: selectedMood ?? this.selectedMood,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    selectedDate,
    meals,
    moodSuggestions,
    moods,
    selectedMood,
    user,
  ];
}
