class Mood {
  int id;
  String moodName;
  String description;
  DateTime recordedAt;

  Mood({
    required this.id,
    required this.moodName,
    required this.description,
    required this.recordedAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) => Mood(
    id: json["id"],
    moodName: json["moodName"],
    description: json["description"],
    recordedAt: DateTime.parse(json["recordedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "moodName": moodName,
    "description": description,
    "recordedAt": recordedAt.toIso8601String(),
  };
}
