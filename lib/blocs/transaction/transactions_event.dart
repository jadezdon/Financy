part of 'transactions_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class GetTransactionsEvent extends TransactionEvent {
  final DateTimeRange dateRange;
  const GetTransactionsEvent(this.dateRange);
  @override
  List<Object> get props => [dateRange];
}

class AddTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [];
}

class UpdateTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object> get props => [];
}

class DeleteTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  const DeleteTransactionEvent(this.transaction);

  @override
  List<Object> get props => [];
}
