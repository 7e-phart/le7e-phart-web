import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc() : super(FinanceInitial()) {
    on<LoadFinances>(_onLoadFinances);
    on<AddTransaction>(_onAddTransaction);
    on<AddExpense>(_onAddExpense);
    on<AddIncome>(_onAddIncome);
  }

  Future<void> _onLoadFinances(
    LoadFinances event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final transactions = [
      Transaction(
        id: '1',
        type: TransactionType.income,
        category: 'Cotisation',
        amount: 20.0,
        date: DateTime(2026, 7, 1),
        description: 'Cotisation Jean Dupont',
      ),
      Transaction(
        id: '2',
        type: TransactionType.income,
        category: 'Subvention',
        amount: 500.0,
        date: DateTime(2026, 6, 15),
        description: 'Subvention ville de Dunkerque',
      ),
      Transaction(
        id: '3',
        type: TransactionType.expense,
        category: 'Équipement',
        amount: 150.0,
        date: DateTime(2026, 6, 20),
        description: 'Achat matériel de tournage',
      ),
      Transaction(
        id: '4',
        type: TransactionType.expense,
        category: 'Location',
        amount: 200.0,
        date: DateTime(2026, 6, 25),
        description: 'Location salle projection',
      ),
      Transaction(
        id: '5',
        type: TransactionType.income,
        category: 'Cotisation',
        amount: 50.0,
        date: DateTime(2026, 7, 5),
        description: 'Cotisation Marie Martin',
      ),
    ];

    final budget = 10000.0;
    final currentBalance = transactions.fold<double>(
      0.0,
      (sum, transaction) =>
          transaction.type == TransactionType.income ? sum + transaction.amount : sum - transaction.amount,
    );

    emit(FinanceLoaded(
      transactions: transactions,
      budget: budget,
      currentBalance: currentBalance,
    ));
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<FinanceState> emit,
  ) async {
    if (state is FinanceLoaded) {
      final currentState = state as FinanceLoaded;
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: event.type,
        category: event.category,
        amount: event.amount,
        date: DateTime.now(),
        description: event.description,
      );

      final newBalance = event.type == TransactionType.income
          ? currentState.currentBalance + event.amount
          : currentState.currentBalance - event.amount;

      emit(currentState.copyWith(
        transactions: [newTransaction, ...currentState.transactions],
        currentBalance: newBalance,
      ));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<FinanceState> emit,
  ) async {
    add(AddTransaction(
      type: TransactionType.expense,
      category: event.category,
      amount: event.amount,
      description: event.description,
    ));
  }

  Future<void> _onAddIncome(
    AddIncome event,
    Emitter<FinanceState> emit,
  ) async {
    add(AddTransaction(
      type: TransactionType.income,
      category: event.category,
      amount: event.amount,
      description: event.description,
    ));
  }
}

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });
}
