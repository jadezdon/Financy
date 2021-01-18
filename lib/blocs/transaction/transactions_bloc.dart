import 'dart:async';
import 'dart:io';

import 'package:Financy/data/models/location_model.dart';
import 'package:Financy/data/repositories/location_repository.dart';
import 'package:Financy/utils/number_util.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/ledger_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../utils/date_util.dart';
import '../ledger/ledger_bloc.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionEvent, TransactionsState> {
  final LedgerBloc ledgerBloc;
  final TransactionRepository repository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final LocationRepository locationRepository;
  StreamSubscription ledgerSubscription;

  TransactionsBloc(
    this.ledgerBloc,
    this.repository,
    this.accountRepository,
    this.categoryRepository,
    this.locationRepository,
  ) : super(TransactionsInitial()) {
    ledgerSubscription = ledgerBloc.listen((state) {
      if (state is LedgerLoaded) {
        add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now())));
      }
    });
  }

  @override
  Stream<TransactionsState> mapEventToState(
    TransactionEvent event,
  ) async* {
    if (event is GetTransactionsEvent) {
      yield TransactionsLoading();
      yield* _mapGetTransactionsEventToState(event);
    } else if (event is AddTransactionEvent) {
      yield* _mapAddTransactionEventToState(event);
    } else if (event is UpdateTransactionEvent) {
      yield* _mapUpdateTransactionEventToState(event);
    } else if (event is DeleteTransactionEvent) {
      yield* _mapDeleteTransactionEventToState(event);
    }
  }

  Stream<TransactionsState> _mapGetTransactionsEventToState(GetTransactionsEvent event) async* {
    try {
      if (ledgerBloc.state is LedgerLoaded) {
        List<TransactionModel> transactions =
            await repository.getAllByLedgerId((ledgerBloc.state as LedgerLoaded).ledger.id);
        List<AccountModel> accounts = await accountRepository.getAll();
        List<CategoryModel> categories = await categoryRepository.getAll();
        List<LocationModel> locations = await locationRepository.getAll();

        //* initialize ledger, account, category, location, transferAccount by its id's
        transactions.forEach((transaction) {
          transaction.account = accounts.firstWhere((element) => element.id == transaction.accountId);
          transaction.category = categories.firstWhere((element) => element.id == transaction.categoryId);
          if (transaction.locationId != null) {
            transaction.location = locations.firstWhere((element) => element.id == transaction.locationId);
          }
          if (transaction.category.transactionType == TransactionType.TRANSFER) {
            transaction.transferAccount = accounts.firstWhere((element) => element.id == transaction.transferAccountId);
          }
          transaction.ledger = (ledgerBloc.state as LedgerLoaded).ledger;
        });

        List<TransactionModel> filteredTransactions =
            transactions.where((element) => DateUtil.isInDataRange(event.dateRange, element.date)).toList();

        filteredTransactions.sort((a, b) {
          DateTime aDate = a.date;
          DateTime bDate = b.date;
          return bDate.compareTo(aDate);
        });

        yield TransactionsLoaded(
          filteredTransactions,
          event.dateRange,
          (ledgerBloc.state as LedgerLoaded).ledger,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      yield TransactionsNotLoaded();
    }
  }

  Stream<TransactionsState> _mapAddTransactionEventToState(AddTransactionEvent event) async* {
    if (state is TransactionsLoaded) {
      //* initialize id's from objects
      event.transaction.ledgerId = (ledgerBloc.state as LedgerLoaded).ledger.id;
      event.transaction.accountId = event.transaction.account.id;
      event.transaction.categoryId = event.transaction.category.id;
      if (event.transaction.location != null) {
        LocationModel updatedLocation = await locationRepository.insert(event.transaction.location);
        event.transaction.locationId = updatedLocation.id;
      }
      if (event.transaction.category.transactionType == TransactionType.TRANSFER) {
        event.transaction.transferAccountId = event.transaction.transferAccount.id;
      }

      final updatedTransaction = await repository.insert(event.transaction);

      final updatedTransactions = List<TransactionModel>.from((state as TransactionsLoaded).transactions)
        ..add(updatedTransaction);

      yield TransactionsLoaded(
        updatedTransactions,
        DateUtil.getCurrentMonth(DateTime.now()),
        (ledgerBloc.state as LedgerLoaded).ledger,
      );
    }
  }

  Stream<TransactionsState> _mapUpdateTransactionEventToState(UpdateTransactionEvent event) async* {
    if (state is TransactionsLoaded) {
      //* initialize id's from objects
      event.transaction.accountId = event.transaction.account.id;
      event.transaction.categoryId = event.transaction.category.id;
      if (event.transaction.category.transactionType == TransactionType.TRANSFER) {
        event.transaction.transferAccountId = event.transaction.transferAccount.id;
      }

      //* update location
      if (event.transaction.locationId != null && event.transaction.location == null) {
        await locationRepository.delete(LocationModel.withId(id: event.transaction.locationId));
        event.transaction.locationId = null;
      } else if (event.transaction.locationId != null && event.transaction.location != null) {
        await locationRepository.update(event.transaction.location);
      } else if (event.transaction.locationId == null && event.transaction.location != null) {
        LocationModel updatedLocation = await locationRepository.insert(event.transaction.location);
        event.transaction.location = updatedLocation;
      }

      //* update transaction
      await repository.update(event.transaction);

      final updatedTransactions = (state as TransactionsLoaded)
          .transactions
          .map((transaction) => transaction.id == event.transaction.id ? event.transaction : transaction)
          .toList();

      yield TransactionsLoaded(
        updatedTransactions,
        DateUtil.getCurrentMonth(DateTime.now()),
        (ledgerBloc.state as LedgerLoaded).ledger,
      );
    }
  }

  Stream<TransactionsState> _mapDeleteTransactionEventToState(DeleteTransactionEvent event) async* {
    if (state is TransactionsLoaded) {
      final updatedTransactions = (state as TransactionsLoaded)
          .transactions
          .where((transaction) => transaction.id != event.transaction.id)
          .toList();

      yield TransactionsLoaded(
        updatedTransactions,
        DateUtil.getCurrentMonth(DateTime.now()),
        (ledgerBloc.state as LedgerLoaded).ledger,
      );

      if (event.transaction.imgUrl != "") {
        await File(event.transaction.imgUrl).delete();
      }
      if (event.transaction.location != null) {
        await locationRepository.delete(event.transaction.location);
      }
      if (event.transaction.category.transactionType == TransactionType.TRANSFER) {
        event.transaction.account.balance += event.transaction.amount;
        event.transaction.transferAccount.balance -= event.transaction.amount;
        await accountRepository.update(event.transaction.account);
        await accountRepository.update(event.transaction.transferAccount);
      } else {
        event.transaction.account.balance += event.transaction.category.transactionType == TransactionType.EXPENSE
            ? event.transaction.amount
            : (-1) * event.transaction.amount;
        await accountRepository.update(event.transaction.account);
      }
      await repository.delete(event.transaction);
    }
  }

  @override
  Future<void> close() {
    ledgerSubscription?.cancel();
    return super.close();
  }
}
