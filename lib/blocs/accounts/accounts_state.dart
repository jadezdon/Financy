part of 'accounts_bloc.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object> get props => [];
}

class AccountsInitial extends AccountsState {
  const AccountsInitial();
  @override
  List<Object> get props => [];
}

class AccountsLoading extends AccountsState {
  const AccountsLoading();
  @override
  List<Object> get props => [];
}

class AccountsLoaded extends AccountsState {
  final List<AccountModel> accounts;
  const AccountsLoaded(this.accounts);
  @override
  List<Object> get props => [accounts];
}

class AccountsNotLoaded extends AccountsState {
  const AccountsNotLoaded();
  @override
  List<Object> get props => [];
}
