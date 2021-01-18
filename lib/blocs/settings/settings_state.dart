part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final int transactionsNumber;
  final int useTimeInDay;
  const SettingsLoaded(this.transactionsNumber, this.useTimeInDay);
  @override
  List<Object> get props => [transactionsNumber, useTimeInDay];
}

class SettingsNotLoaded extends SettingsState {}
