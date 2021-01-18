import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/transaction/transactions_bloc.dart';
import '../config/route.dart';
import '../config/theme.dart';
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';
import 'base_dialog.dart';
import 'money_text.dart';

class TransactionDetailDialog extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailDialog({Key key, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      titleWidget: Flexible(
        child: Row(
          children: [
            Icon(
              IconData(
                transaction.category.iconCodePoint,
                fontFamily: transaction.category.iconFamily,
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
              child: Text(
                transaction.category.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            MoneyText(
              value: transaction.amount,
              transactionType: transaction.category.transactionType,
              fontSize: AppSize.fontLarge,
            ),
          ],
        ),
      ),
      contentWidget: Column(
        children: [
          Table(
            columnWidths: {
              0: FractionColumnWidth(.15),
              1: FractionColumnWidth(.25),
              2: FractionColumnWidth(.6),
            },
            children: [
              if (transaction.category.transactionType != TransactionType.TRANSFER)
                _buildRow(Icons.credit_card_outlined, tr("account"), transaction.account.name),
              if (transaction.category.transactionType == TransactionType.TRANSFER)
                _buildRow(Icons.credit_card_outlined, tr("from"), transaction.account.name),
              if (transaction.category.transactionType == TransactionType.TRANSFER)
                _buildRow(Icons.credit_card_outlined, tr("to"), transaction.transferAccount.name),
              _buildRow(Icons.today_outlined, tr("date"), DateFormat("yyyy-MM-dd").format(transaction.date)),
              _buildRow(
                Icons.location_on_outlined,
                tr("location"),
                transaction.location != null
                    ? "${transaction.location.country}, ${transaction.location.city}, ${transaction.location.street} ${transaction.location.houseNumber}."
                    : "",
              ),
              _buildRow(Icons.comment_outlined, tr("comment"), transaction.remark),
              if (transaction.personName != "") _buildRow(Icons.face_outlined, tr("member"), transaction.personName),
              TableRow(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Icon(Icons.photo_outlined),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      tr("photo"),
                      style: TextStyle(color: AppColor.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  transaction.imgUrl == ""
                      ? SizedBox.shrink()
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.2,
                          padding: EdgeInsets.symmetric(vertical: 7),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.file(File(transaction.imgUrl)),
                          ),
                        ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoute.addTransactionPage,
                    arguments: transaction,
                  );
                },
                icon: Icon(Icons.edit_outlined),
                label: Text(tr("edit")),
              ),
              FlatButton.icon(
                onPressed: () {
                  BlocProvider.of<TransactionsBloc>(context).add(DeleteTransactionEvent(transaction));
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.delete_outline_outlined,
                  color: AppColor.red,
                ),
                label: Text(
                  tr("delete"),
                  style: TextStyle(color: AppColor.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(IconData iconData, String label, String content) {
    return TableRow(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: Icon(iconData),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: Text(
            label,
            style: TextStyle(color: AppColor.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: Text(
            content,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
