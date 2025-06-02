import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrients_manager/bloc/home/home_event.dart';
import 'package:nutrients_manager/bloc/home/home_state.dart';
import 'package:nutrients_manager/data/repository/meal_repository.dart';
import 'package:nutrients_manager/data/repository/mood_repository.dart';
import 'package:nutrients_manager/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(HomeState(selectedDate: DateTime.now())) {
    on<LoadHomeData>(_onLoadHomeData);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectMoodEvent>(_onSelectMood);
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final user = await UserRepositoryImpl.instance.fetchUserById(uid!);

      final fetchedMeals =
      await MealRepositoryImpl.instance.fetchAllMealsWithRecipes();

      final fetchedMoods =
      await MoodRepositoryImp.instance.fetchAllMoods();
      final moods = fetchedMoods.map((e) => e.moodName).toList();
      final defaultMood = moods.isNotEmpty ? moods[0] : '';

      final moodId = moods.indexOf(defaultMood) + 1;
      final moodSuggestions =
      await MoodRepositoryImp.instance.fetchMoodRecipes(moodId);

      emit(state.copyWith(
        isLoading: false,
        meals: fetchedMeals,
        moods: moods,
        selectedMood: defaultMood,
        moodSuggestions: moodSuggestions,
        user: user,
      ));
    } catch (e) {
      print("Error loading home data: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onSelectDate(SelectDateEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onSelectMood(SelectMoodEvent event, Emitter<HomeState> emit) async {
    final moodId = state.moods.indexOf(event.mood) + 1;
    final moodSuggestions =
    await MoodRepositoryImp.instance.fetchMoodRecipes(moodId);
    emit(state.copyWith(
      selectedMood: event.mood,
      moodSuggestions: moodSuggestions,
    ));
  }
}
