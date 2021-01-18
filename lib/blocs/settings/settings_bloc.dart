import 'dart:async';

import 'package:Financy/data/models/transaction_model.dart';
import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:Financy/utils/number_util.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final TransactionRepository transactionRepository;
  SettingsBloc(this.transactionRepository) : super(SettingsInitial());

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is GetDataEvent) {
      yield* _mapGetDataEventToState(event);
    }
  }

  Stream<SettingsState> _mapGetDataEventToState(GetDataEvent event) async* {
    try {
      List<TransactionModel> transactions = await transactionRepository.getAll();
      int transactionsNumber = transactions.length;
      transactions.sort((a, b) {
        DateTime aDate = a.date;
        DateTime bDate = b.date;
        return aDate.compareTo(bDate);
      });
      int useTimeInDay = transactionsNumber > 0 ? DateUtil.durationInDay(transactions.first.date, DateTime.now()) : 0;
      yield SettingsLoaded(transactionsNumber, useTimeInDay);
    } catch (e) {
      dPrint(e.toString());
      yield SettingsNotLoaded();
    }
  }
}
