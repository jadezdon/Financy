import 'package:Financy/data/models/location_model.dart';
import 'package:equatable/equatable.dart';

import 'account_model.dart';
import 'category_model.dart';
import 'ledger_model.dart';

// ignore: must_be_immutable
class TransactionModel extends Equatable {
  static final tblTransaction = "t_transaction";
  static final colId = "id";
  static final colAmount = "amount";
  static final colDate = "date";
  static final colRemark = "remark";
  static final colCategoryId = "category_id";
  static final colAccountId = "account_id";
  static final colLedgerId = "ledger_id";
  static final colLocationId = "location_id";
  static final colImgUrl = "img_url";
  static final colContact = "person_name";
  static final colTransferAccountId = "transfer_account_id";

  int id;
  double amount;
  DateTime date;
  String remark;
  String imgUrl;
  String personName;
  int categoryId;
  int accountId;
  int ledgerId;
  int locationId;
  int transferAccountId;

  CategoryModel category;
  AccountModel account;
  LedgerModel ledger;
  LocationModel location;
  AccountModel transferAccount;

  TransactionModel({
    this.amount = 0.0,
    this.date,
    this.remark = "",
    this.imgUrl = "",
    this.personName = "",
    this.categoryId,
    this.accountId,
    this.transferAccountId,
    this.ledgerId,
    this.locationId,
    this.category,
    this.account,
    this.ledger,
    this.location,
    this.transferAccount,
  });

  TransactionModel.withId({
    this.id,
    this.amount = 0.0,
    this.date,
    this.remark = "",
    this.imgUrl = "",
    this.personName = "",
    this.categoryId,
    this.accountId,
    this.transferAccountId,
    this.ledgerId,
    this.locationId,
    this.category,
    this.account,
    this.ledger,
    this.location,
    this.transferAccount,
  });

  TransactionModel clone() {
    return TransactionModel.withId(
      id: this.id,
      amount: this.amount,
      date: this.date,
      remark: this.remark,
      categoryId: this.categoryId,
      category: this.category,
      accountId: this.accountId,
      account: this.account,
      ledgerId: this.ledgerId,
      locationId: this.locationId,
      ledger: this.ledger,
      imgUrl: this.imgUrl,
      personName: this.personName,
      location: this.location,
      transferAccountId: this.transferAccountId,
      transferAccount: this.transferAccount,
    );
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map[colId] = id;
    }
    map[colAmount] = amount;
    map[colDate] = date.toString();
    map[colRemark] = remark;
    map[colCategoryId] = categoryId;
    map[colAccountId] = accountId;
    map[colLedgerId] = ledgerId;
    map[colImgUrl] = imgUrl;
    map[colContact] = personName;
    map[colLocationId] = locationId;
    map[colTransferAccountId] = transferAccountId;
    return map;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel.withId(
      id: map[colId],
      amount: map[colAmount],
      date: DateTime.tryParse(map[colDate]),
      remark: map[colRemark],
      categoryId: map[colCategoryId],
      accountId: map[colAccountId],
      ledgerId: map[colLedgerId],
      imgUrl: map[colImgUrl],
      personName: map[colContact],
      locationId: map[colLocationId],
      transferAccountId: map[colTransferAccountId],
    );
  }

  @override
  List<Object> get props => [
        id,
        amount,
        date,
        remark,
        categoryId,
        accountId,
        ledgerId,
        imgUrl,
        personName,
        locationId,
        transferAccountId,
      ];

  @override
  String toString() {
    return "[Transaction] id = $id, amount = $amount, date = $date, remark = $remark, categoryId = $categoryId, accountId = $accountId, transferAccountId = $transferAccountId, ledgerId = $ledgerId, locationId = $locationId";
  }
}
