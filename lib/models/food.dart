class Food {
  String? id;
  String? foodDate;
  String? foodMeal;
  String? foodName;
  double? foodPrice;
  int? foodPerson;
  String? foodImageUrl;

  Food({
    this.id,
    this.foodDate,
    this.foodMeal,
    this.foodName,
    this.foodPrice,
    this.foodPerson,
    this.foodImageUrl,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String?,
      foodDate: json['foodDate'] as String?,
      foodMeal: json['foodMeal'] as String?,
      foodName: json['foodName'] as String?,
      foodPrice: (json['foodPrice'] as num?)?.toDouble(),
      foodPerson: json['foodPerson'] as int?,
      foodImageUrl: json['foodImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'foodDate': foodDate,
      'foodMeal': foodMeal,
      'foodName': foodName,
      'foodPrice': foodPrice,
      'foodPerson': foodPerson,
      'foodImageUrl': foodImageUrl,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}