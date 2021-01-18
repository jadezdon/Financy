import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class AccountModel extends Equatable {
  static final tblAccount = "t_account";
  static final colId = "id";
  static final colName = "name";
  static final colBalance = "balance";
  static final colIconCodePoint = "icon_code_point";
  static final colIconFamily = "icon_family";
  static final colTransactionType = "transaction_type";

  int id;
  String name;
  double balance = 0.0;
  int iconCodePoint;
  String iconFamily;

  AccountModel({
    this.name,
    this.balance,
    this.iconCodePoint,
    this.iconFamily,
  });
  AccountModel.withId({
    this.id,
    this.name,
    this.balance,
    this.iconCodePoint,
    this.iconFamily,
  });

  AccountModel clone() {
    return AccountModel.withId(
      id: this.id,
      name: this.name,
      balance: this.balance,
      iconCodePoint: this.iconCodePoint,
      iconFamily: this.iconFamily,
    );
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map[colId] = id;
    }
    map[colName] = name;
    map[colIconCodePoint] = iconCodePoint;
    map[colIconFamily] = iconFamily;
    map[colBalance] = balance;

    return map;
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel.withId(
      id: map[colId],
      name: map[colName],
      balance: map[colBalance] ?? 0,
      iconCodePoint: map[colIconCodePoint],
      iconFamily: map[colIconFamily],
    );
  }

  @override
  List<Object> get props => [id, name, balance];
}
