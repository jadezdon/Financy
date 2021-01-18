part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class GetDataEvent extends SettingsEvent {
  const GetDataEvent();

  @override
  List<Object> get props => [];
}
