import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class LedgerModel extends Equatable {
  static final tblLedger = "t_ledger";
  static final colId = "id";
  static final colName = "name";
  static final colBudget = "budget";

  int id;
  String name;
  double budget = 0.0;

  LedgerModel({
    this.name,
    this.budget = 0.0,
  });

  LedgerModel.withId({
    this.id,
    this.name,
    this.budget = 0.0,
  });

  LedgerModel clone() {
    return LedgerModel.withId(
      id: this.id,
      name: this.name,
      budget: this.budget,
    );
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map[colId] = id;
    }
    map[colName] = name;
    map[colBudget] = budget;
    return map;
  }

  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel.withId(
      id: map[colId],
      name: map[colName],
      budget: map[colBudget],
    );
  }

  @override
  List<Object> get props => [id, name, budget];
}
