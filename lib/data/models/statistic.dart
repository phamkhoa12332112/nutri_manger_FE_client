class Statistic {
  int id;
  DateTime intakeDate;
  double dailyCaloriesGoal;
  double totalCalories;
  String goalStatus;

  Statistic({
    required this.id,
    required this.intakeDate,
    required this.dailyCaloriesGoal,
    required this.totalCalories,
    required this.goalStatus,
  });

  factory Statistic.fromJson(Map<String, dynamic> json) => Statistic(
    id: json["id"],
    intakeDate: DateTime.parse(json["intakeDate"]),
    dailyCaloriesGoal: json["dailyCaloriesGoal"]?.toDouble(),
    totalCalories: json["totalCalories"]?.toDouble(),
    goalStatus: json["goalStatus"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "intakeDate": intakeDate.toIso8601String(),
    "dailyCaloriesGoal": dailyCaloriesGoal,
    "totalCalories": totalCalories,
    "goalStatus": goalStatus,
  };
}