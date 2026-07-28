class TransactionModel {
  final String id;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      type: data['type'] ?? 'income',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['date'])
          : DateTime.now(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }
}
