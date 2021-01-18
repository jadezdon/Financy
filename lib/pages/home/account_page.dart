import 'package:Financy/blocs/transaction/transactions_bloc.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../blocs/accounts/accounts_bloc.dart';
import '../../config/route.dart';
import '../../config/theme.dart';
import '../../data/models/account_model.dart';
import '../../widgets/error.dart';
import '../../widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          // return Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   child: Center(child: CircularProgressIndicator()),
          // );
          return SizedBox.shrink();
        } else if (state is AccountsLoaded) {
          return _buildPage(context, state.accounts);
        } else if (state is AccountsNotLoaded) {
          return ErrorContainer(msg: "Accounts not loaded");
        } else if (state is AccountsInitial) {
          return SizedBox.shrink();
        }
        return ErrorContainer(msg: "Accounts no state");
      },
    );
  }

  Widget _buildPage(BuildContext context, List<AccountModel> accounts) {
    double total = accounts.fold(0.0, (previousValue, element) => previousValue + (element.balance ?? 0));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, total),
        ...accounts.map((e) => _buildAccountItem(context, e)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori, vertical: 5),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.addAccountPage);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_box_outlined, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    tr("add account"),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, double total) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[400], width: 0.4),
      ),
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: AppSize.itemHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(tr("total")),
            SizedBox(width: 10),
            MoneyText(
              value: total,
              fontSize: AppSize.fontLarge,
              fontColor: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: AppSize.pageMarginHori),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, AccountModel account) {
    return Container(
      child: Slidable(
        actionExtentRatio: 0.2,
        actionPane: SlidableDrawerActionPane(),
        child: Card(
          child: Container(
            height: AppSize.itemHeight,
            color: AppColor.colorPalette[account.id % AppColor.colorPalette.length].withOpacity(.3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: double.infinity,
                  color: AppColor.colorPalette[account.id % AppColor.colorPalette.length],
                ),
                SizedBox(width: 10),
                Icon(
                  IconData(account.iconCodePoint, fontFamily: account.iconFamily),
                  // color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  account.name,
                  // style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: MoneyText(
                      value: account.balance,
                      fontSize: AppSize.fontLarge,
                      // fontColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.pageMarginHori),
              ],
            ),
          ),
        ),
        secondaryActions: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: IconSlideAction(
              caption: tr("edit"),
              icon: Icons.edit_outlined,
              color: AppColor.lightgrey,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.addAccountPage,
                  arguments: account,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: IconSlideAction(
              caption: tr("delete"),
              icon: Icons.delete_outline_outlined,
              color: Colors.red,
              onTap: () {
                showConfirmDialog(context, account);
              },
            ),
          ),
        ],
      ),
    );
  }

  void showConfirmDialog(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr("delete account")),
          content: Text(tr(
              "Are you sure that you want to delete this account? All transaction will be deleted in this account.")),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(tr("cancel")),
            ),
            FlatButton(
              onPressed: () {
                BlocProvider.of<AccountsBloc>(context).add(DeleteAccountEvent(account));
                BlocProvider.of<TransactionsBloc>(context)
                    .add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now())));
                Navigator.pop(context);
              },
              child: Text(
                tr("delete"),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
