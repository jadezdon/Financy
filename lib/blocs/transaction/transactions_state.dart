part of 'transactions_bloc.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
  @override
  List<Object> get props => [];
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
  @override
  List<Object> get props => [];
}

class TransactionsLoaded extends TransactionsState {
  final LedgerModel ledger;
  final List<TransactionModel> transactions;
  final DateTimeRange dateRange;
  const TransactionsLoaded(this.transactions, this.dateRange, this.ledger);
  @override
  List<Object> get props => [transactions, dateRange, ledger];
}

class TransactionsNotLoaded extends TransactionsState {
  const TransactionsNotLoaded();
  @override
  List<Object> get props => [];
}
