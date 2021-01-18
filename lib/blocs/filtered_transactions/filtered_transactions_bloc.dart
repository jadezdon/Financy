import 'dart:async';

import 'package:Financy/blocs/ledger/ledger_bloc.dart';
import 'package:Financy/data/models/account_model.dart';
import 'package:Financy/data/models/category_model.dart';
import 'package:Financy/data/models/location_model.dart';
import 'package:Financy/data/models/transaction_model.dart';
import 'package:Financy/data/repositories/account_repository.dart';
import 'package:Financy/data/repositories/category_repository.dart';
import 'package:Financy/data/repositories/location_repository.dart';
import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:Financy/utils/number_util.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'filtered_transactions_event.dart';
part 'filtered_transactions_state.dart';

class FilteredTransactionsBloc extends Bloc<FilteredTransactionsEvent, FilteredTransactionsState> {
  final LedgerBloc ledgerBloc;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final LocationRepository locationRepository;
  StreamSubscription ledgerSubscription;

  FilteredTransactionsBloc(
    this.ledgerBloc,
    this.transactionRepository,
    this.accountRepository,
    this.categoryRepository,
    this.locationRepository,
  ) : super(FilteredTransactionsInitial()) {
    ledgerSubscription = ledgerBloc.listen((state) {
      if (state is LedgerLoaded) {
        add(GetFilteredTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now()), null));
      }
    });
  }

  @override
  Stream<FilteredTransactionsState> mapEventToState(
    FilteredTransactionsEvent event,
  ) async* {
    if (event is GetFilteredTransactionsEvent) {
      yield FilteredTransactionsLoading();
      yield* _mapGetFilteredTransactionsEventToState(event);
    }
  }

  Stream<FilteredTransactionsState> _mapGetFilteredTransactionsEventToState(GetFilteredTransactionsEvent event) async* {
    try {
      if (ledgerBloc.state is LedgerLoaded) {
        List<TransactionModel> transactions =
            await transactionRepository.getAllByLedgerId((ledgerBloc.state as LedgerLoaded).ledger.id);
        List<AccountModel> accounts = await accountRepository.getAll();
        List<CategoryModel> categories = await categoryRepository.getAll();
        List<LocationModel> locations = await locationRepository.getAll();

        transactions.forEach((transaction) {
          transaction.account = accounts.firstWhere((element) => element.id == transaction.accountId);
          transaction.category = categories.firstWhere((element) => element.id == transaction.categoryId);
          if (transaction.locationId != null) {
            transaction.location = locations.firstWhere((element) => element.id == transaction.locationId);
          }
          transaction.ledger = (ledgerBloc.state as LedgerLoaded).ledger;
        });

        List<TransactionModel> transactionsInDateRange = transactions
            .where((element) =>
                DateUtil.isInDataRange(event.dateRange, element.date) &&
                element.category.transactionType != TransactionType.TRANSFER)
            .toList();

        transactionsInDateRange.sort((a, b) {
          DateTime aDate = a.date;
          DateTime bDate = b.date;
          return bDate.compareTo(aDate);
        });

        if (event.transactionType == null) {
          yield FilteredTransactionsLoaded(
            transactionsInDateRange,
            event.dateRange,
            event.transactionType,
          );
        } else {
          List<TransactionModel> transactionByType = transactionsInDateRange
              .where((element) => element.category.transactionType == event.transactionType)
              .toList();
          yield FilteredTransactionsLoaded(
            transactionByType,
            event.dateRange,
            event.transactionType,
          );
        }
      }
    } catch (e) {
      dPrint(e.toString());
      yield FilteredTransactionsNotLoaded();
    }
  }

  @override
  Future<void> close() {
    ledgerSubscription?.cancel();
    return super.close();
  }
}
