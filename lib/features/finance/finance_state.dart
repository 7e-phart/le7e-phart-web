part of 'finance_bloc.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object> get props => [];
}

class FinanceInitial extends FinanceState {
  const FinanceInitial();
}

class FinanceLoading extends FinanceState {
  const FinanceLoading();
}

class FinanceLoaded extends FinanceState {
  final List<Transaction> transactions;
  final double budget;
  final double currentBalance;

  const FinanceLoaded({
    required this.transactions,
    required this.budget,
    required this.currentBalance,
  });

  FinanceLoaded copyWith({
    List<Transaction>? transactions,
    double? budget,
    double? currentBalance,
  }) {
    return FinanceLoaded(
      transactions: transactions ?? this.transactions,
      budget: budget ?? this.budget,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  List<Object> get props => [transactions, budget, currentBalance];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError({required this.message});

  @override
  List<Object> get props => [message];
}
