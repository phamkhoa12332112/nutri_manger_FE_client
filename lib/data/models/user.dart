class UserDTB {
  int id;
  String? name;
  int? age;
  bool? gender;
  double? weight;
  double? weightGoal;
  double? height;
  String email;
  String userId;
  double? dailyCaloriesGoal;
  double? levelExercise;

  UserDTB({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.weightGoal,
    required this.height,
    required this.email,
    required this.userId,
    required this.dailyCaloriesGoal,
    required this.levelExercise,
  });

  factory UserDTB.fromJson(Map<String, dynamic> json) => UserDTB(
    id: json["id"],
    name: json["name"],
    age: json["age"],
    gender: json["gender"],
    weight: json["weight"]?.toDouble(),
    weightGoal: json["weightGoal"]?.toDouble(),
    height: json["height"]?.toDouble(),
    email: json["email"],
    userId: json["userId"],
    dailyCaloriesGoal: json["dailyCaloriesGoal"]?.toDouble(),
    levelExercise: json["levelExercise"]?.toDouble(),
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "age": age,
    "gender": gender,
    "weight": weight,
    "weightGoal": weightGoal,
    "height": height,
    "email": email,
    "userId": userId,
    "dailyCaloriesGoal": dailyCaloriesGoal,
    "levelExercise": levelExercise,
  };
}