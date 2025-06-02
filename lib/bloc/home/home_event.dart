import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class SelectDateEvent extends HomeEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectMoodEvent extends HomeEvent {
  final String mood;

  const SelectMoodEvent(this.mood);

  @override
  List<Object?> get props => [mood];
}
