part of 'filtered_transactions_bloc.dart';

abstract class FilteredTransactionsEvent extends Equatable {
  const FilteredTransactionsEvent();

  @override
  List<Object> get props => [];
}

class GetFilteredTransactionsEvent extends FilteredTransactionsEvent {
  final TransactionType transactionType;
  final DateTimeRange dateRange;
  const GetFilteredTransactionsEvent(this.dateRange, this.transactionType);
  @override
  List<Object> get props => [dateRange, transactionType];
}
