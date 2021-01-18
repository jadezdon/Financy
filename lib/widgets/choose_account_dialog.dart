import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/accounts/accounts_bloc.dart';
import '../data/models/account_model.dart';
import 'base_dialog.dart';
import 'error.dart';
import 'money_text.dart';

class ChooseAccountDialog extends StatelessWidget {
  final AccountModel selectedAccount;
  const ChooseAccountDialog({Key key, this.selectedAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AccountsLoaded) {
          return _buildDialog(context, state.accounts);
        } else if (state is AccountsNotLoaded) {
          return ErrorContainer(msg: "Accounts not loaded");
        }

        return ErrorContainer(msg: "No AccountsState");
      },
    );
  }

  Widget _buildDialog(BuildContext context, List<AccountModel> accountList) {
    return BaseDialog(
      titleWidget: Text(tr("choose-account")),
      contentWidget: Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: accountList.length,
          itemBuilder: (BuildContext context, int index) {
            return SimpleDialogOption(
              padding: EdgeInsets.all(0),
              onPressed: () => Navigator.pop(context, accountList[index]),
              child: _buildAccountContainer(context, accountList[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountContainer(BuildContext context, AccountModel account) {
    BoxDecoration boxDecoration = BoxDecoration();
    Color color = Colors.black;
    if (account == selectedAccount) {
      boxDecoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      );
      color = Theme.of(context).accentColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: boxDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            account.name,
            style: TextStyle(color: color),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: MoneyText(
                value: account.balance,
                fontColor: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
