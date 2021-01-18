import 'dart:async';

import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  AccountsBloc(
    this.accountRepository,
    this.transactionRepository,
  ) : super(AccountsInitial());

  @override
  Stream<AccountsState> mapEventToState(
    AccountsEvent event,
  ) async* {
    if (event is GetAccountsEvent) {
      yield AccountsLoading();
      yield* _mapGetAccountsEventToState(event);
    } else if (event is AddAccountEvent) {
      yield* _mapAddAccountEventToState(event);
    } else if (event is UpdateAccountEvent) {
      yield* _mapUpdateAccountEventToState(event);
    } else if (event is DeleteAccountEvent) {
      yield* _mapDeleteAccountEventToState(event);
    }
  }

  Stream<AccountsState> _mapGetAccountsEventToState(
      GetAccountsEvent event) async* {
    try {
      List<AccountModel> accounts = await accountRepository.getAll();
      yield AccountsLoaded(accounts);
    } catch (e) {
      debugPrint(e.toString());
      yield AccountsNotLoaded();
    }
  }

  Stream<AccountsState> _mapAddAccountEventToState(
      AddAccountEvent event) async* {
    if (state is AccountsLoaded) {
      AccountModel updatedAccount =
          await accountRepository.insert(event.account);
      List<AccountModel> updatedAccounts =
          List<AccountModel>.from((state as AccountsLoaded).accounts)
            ..add(updatedAccount);
      yield AccountsLoaded(updatedAccounts);
    }
  }

  Stream<AccountsState> _mapUpdateAccountEventToState(
      UpdateAccountEvent event) async* {
    if (state is AccountsLoaded) {
      List<AccountModel> updatedAccounts = (state as AccountsLoaded)
          .accounts
          .map((e) => e.id == event.account.id ? event.account : e)
          .toList();
      yield AccountsLoaded(updatedAccounts);
      await accountRepository.update(event.account);
    }
  }

  Stream<AccountsState> _mapDeleteAccountEventToState(
      DeleteAccountEvent event) async* {
    if (state is AccountsLoaded) {
      List<AccountModel> updatedAccounts = (state as AccountsLoaded)
          .accounts
          .where((a) => a.id != event.account.id)
          .toList();
      yield AccountsLoaded(updatedAccounts);
      await transactionRepository.deleteAllByAccountId(event.account.id);
      await accountRepository.delete(event.account);
    }
  }
}
