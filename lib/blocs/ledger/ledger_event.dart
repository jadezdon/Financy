part of 'ledger_bloc.dart';

abstract class LedgerEvent extends Equatable {
  const LedgerEvent();

  @override
  List<Object> get props => [];
}

class AddLedgerEvent extends LedgerEvent {
  final LedgerModel ledger;
  const AddLedgerEvent(this.ledger);

  @override
  List<Object> get props => [ledger];
}

class GetLedgerEvent extends LedgerEvent {
  final int ledgerId;
  const GetLedgerEvent(this.ledgerId);

  @override
  List<Object> get props => [ledgerId];
}

class GetLedgersEvent extends LedgerEvent {
  const GetLedgersEvent();

  @override
  List<Object> get props => [];
}

class UpdateLedgerEvent extends LedgerEvent {
  final LedgerModel ledger;
  const UpdateLedgerEvent(this.ledger);

  @override
  List<Object> get props => [ledger];
}

class DeleteLedgerEvent extends LedgerEvent {
  final LedgerModel ledger;
  const DeleteLedgerEvent(this.ledger);

  @override
  List<Object> get props => [ledger];
}
