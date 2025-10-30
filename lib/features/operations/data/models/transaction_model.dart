class TransactionModel {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final String date;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'date': date,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
