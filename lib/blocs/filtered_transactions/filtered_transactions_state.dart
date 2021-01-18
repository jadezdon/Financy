part of 'filtered_transactions_bloc.dart';

abstract class FilteredTransactionsState extends Equatable {
  const FilteredTransactionsState();

  @override
  List<Object> get props => [];
}

class FilteredTransactionsInitial extends FilteredTransactionsState {
  const FilteredTransactionsInitial();
  @override
  List<Object> get props => [];
}

class FilteredTransactionsLoading extends FilteredTransactionsState {
  const FilteredTransactionsLoading();
  @override
  List<Object> get props => [];
}

class FilteredTransactionsLoaded extends FilteredTransactionsState {
  final List<TransactionModel> transactions;
  final DateTimeRange dateRange;
  final TransactionType transactionType;
  const FilteredTransactionsLoaded(this.transactions, this.dateRange, this.transactionType);
  @override
  List<Object> get props => [transactions, dateRange];
}

class FilteredTransactionsNotLoaded extends FilteredTransactionsState {
  const FilteredTransactionsNotLoaded();
  @override
  List<Object> get props => [];
}
