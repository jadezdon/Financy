part of 'ledger_bloc.dart';

abstract class LedgerState extends Equatable {
  const LedgerState();

  @override
  List<Object> get props => [];
}

class LedgerInitial extends LedgerState {}

class LedgerLoading extends LedgerState {}

class LedgersLoaded extends LedgerState {
  final List<LedgerModel> ledgers;
  const LedgersLoaded(this.ledgers);

  @override
  List<Object> get props => [ledgers];
}

class LedgerLoaded extends LedgerState {
  final LedgerModel ledger;
  const LedgerLoaded(this.ledger);

  @override
  List<Object> get props => [ledger];
}

class LedgerNotLoaded extends LedgerState {}
