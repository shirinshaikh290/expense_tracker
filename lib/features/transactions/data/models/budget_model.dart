class BudgetModel {
  final int? id;
  final String category;
  final double limitAmount;

  BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'limitAmount': limitAmount,
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limitAmount: map['limitAmount'],
    );
  }
}
