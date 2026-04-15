class SeasonModel {
  final String id;
  final bool published;

  SeasonModel({
    required this.id,
    required this.published,
  });

  factory SeasonModel.fromMap(String id, Map<String, dynamic> map) {
    return SeasonModel(
      id: id,
      published: map['published'] ?? false,
    );
  }
}