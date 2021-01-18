import 'dart:async';

import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/ledger_model.dart';
import '../../data/repositories/ledger_repository.dart';

part 'ledger_event.dart';
part 'ledger_state.dart';

class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  final LedgerRepository ledgerRepository;
  final TransactionRepository transactionRepository;

  LedgerBloc(
    this.ledgerRepository,
    this.transactionRepository,
  ) : super(LedgerInitial());

  @override
  Stream<LedgerState> mapEventToState(
    LedgerEvent event,
  ) async* {
    if (event is GetLedgersEvent) {
      yield* _mapGetLedgersEventToState(event);
    } else if (event is GetLedgerEvent) {
      yield* _mapGetLedgerEventToState(event);
    } else if (event is UpdateLedgerEvent) {
      yield* _mapUpdateLedgerEventToState(event);
    } else if (event is AddLedgerEvent) {
      yield* _mapAddLedgerEventToState(event);
    } else if (event is DeleteLedgerEvent) {
      yield* _mapDeleteLedgerEventToState(event);
    }
  }

  Stream<LedgerState> _mapGetLedgersEventToState(GetLedgersEvent event) async* {
    try {
      List<LedgerModel> ledgers = await ledgerRepository.getAll();
      yield LedgersLoaded(ledgers);
    } catch (e) {
      debugPrint(e.toString());
      yield LedgerNotLoaded();
    }
  }

  Stream<LedgerState> _mapGetLedgerEventToState(GetLedgerEvent event) async* {
    try {
      LedgerModel ledger = await ledgerRepository.getById(event.ledgerId);
      yield LedgerLoaded(ledger);
    } catch (e) {
      debugPrint(e.toString());
      yield LedgerNotLoaded();
    }
  }

  Stream<LedgerState> _mapAddLedgerEventToState(AddLedgerEvent event) async* {
    try {
      LedgerModel ledger = await ledgerRepository.insert(event.ledger);
      yield LedgerLoaded(ledger);
    } catch (e) {
      debugPrint(e.toString());
      yield LedgerNotLoaded();
    }
  }

  Stream<LedgerState> _mapUpdateLedgerEventToState(
      UpdateLedgerEvent event) async* {
    try {
      await ledgerRepository.update(event.ledger);
      yield LedgerLoaded(event.ledger);
    } catch (e) {
      debugPrint(e.toString());
      yield LedgerNotLoaded();
    }
  }

  Stream<LedgerState> _mapDeleteLedgerEventToState(
      DeleteLedgerEvent event) async* {
    try {
      await transactionRepository.deleteAllByLedgerId(event.ledger.id);
      await ledgerRepository.delete(event.ledger);
      List<LedgerModel> ledgers = await ledgerRepository.getAll();
      yield LedgerLoaded(ledgers.first);
    } catch (e) {
      debugPrint(e.toString());
      yield LedgerNotLoaded();
    }
  }
}
