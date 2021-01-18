part of 'accounts_bloc.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object> get props => [];
}

class GetAccountsEvent extends AccountsEvent {
  const GetAccountsEvent();
  @override
  List<Object> get props => [];
}

class AddAccountEvent extends AccountsEvent {
  final AccountModel account;
  const AddAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccountEvent extends AccountsEvent {
  final AccountModel account;
  const UpdateAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccountEvent extends AccountsEvent {
  final AccountModel account;
  const DeleteAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}
