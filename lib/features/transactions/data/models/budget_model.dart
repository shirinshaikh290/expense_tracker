class BudgetModel {
  final int? id;
  final String category;
  final double limitAmount;
  final int month;
  final int year;

  BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'limitAmount': limitAmount,
    'month': month,
    'year': year,
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
    id: map['id'],
    category: map['category'],
    limitAmount: map['limitAmount'],
    month: map['month'],
    year: map['year'],
  );
}
