part of 'finance_bloc.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object> get props => [];
}

class LoadFinances extends FinanceEvent {
  const LoadFinances();
}

class AddTransaction extends FinanceEvent {
  final TransactionType type;
  final String category;
  final double amount;
  final String description;

  const AddTransaction({
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [type, category, amount, description];
}

class AddExpense extends FinanceEvent {
  final String category;
  final double amount;
  final String description;

  const AddExpense({
    required this.category,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [category, amount, description];
}

class AddIncome extends FinanceEvent {
  final String category;
  final double amount;
  final String description;

  const AddIncome({
    required this.category,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [category, amount, description];
}
