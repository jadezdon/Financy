import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class CategoryModel extends Equatable {
  static final tblCategory = "t_category";
  static final colId = "id";
  static final colName = "name";
  static final colIconCodePoint = "icon_code_point";
  static final colIconFamily = "icon_family";
  static final colTransactionType = "transaction_type";

  int id;
  String name;
  TransactionType transactionType;
  int iconCodePoint;
  String iconFamily;

  CategoryModel({
    this.name,
    this.iconCodePoint,
    this.transactionType,
    this.iconFamily,
  });
  CategoryModel.withId({
    this.id,
    this.name,
    this.iconCodePoint,
    this.transactionType,
    this.iconFamily,
  });

  CategoryModel clone() {
    return CategoryModel.withId(
      id: this.id,
      name: this.name,
      iconCodePoint: this.iconCodePoint,
      iconFamily: this.iconFamily,
      transactionType: this.transactionType,
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
    map[colTransactionType] = transactionType.toString();
    return map;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel.withId(
      id: map[colId],
      name: map[colName],
      iconCodePoint: map[colIconCodePoint],
      iconFamily: map[colIconFamily],
      transactionType: TransactionType.values.firstWhere((e) => e.toString() == "${map[colTransactionType]}"),
    );
  }

  @override
  List<Object> get props => [id, name, transactionType, iconCodePoint];
}

enum TransactionType { INCOME, EXPENSE, TRANSFER }
