import 'package:Financy/blocs/transaction/transactions_bloc.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/accounts/accounts_bloc.dart';
import '../config/theme.dart';
import '../data/models/account_model.dart';
import '../utils/data.dart';
import '../utils/number_util.dart';
import '../widgets/icon_picker.dart';

class AddAccountPage extends StatefulWidget {
  final AccountModel accountToEdit;
  AddAccountPage({Key key, this.accountToEdit}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  AccountModel account = AccountModel();
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController balanceTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    account.balance = 0;
    account.iconCodePoint = AppData.iconList.first.icon.codePoint;
    account.iconFamily = AppData.iconList.first.icon.fontFamily;

    if (widget.accountToEdit != null) {
      account = widget.accountToEdit.clone();
      nameTextController.text = account.name;
      balanceTextController.text = NumberUtil.doubleToString(account.balance);
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    balanceTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(tr("account")),
        leadingWidth: 0,
        leading: SizedBox.shrink(),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.clear),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 50,
                          child: Center(
                            child: Icon(
                              IconData(
                                account.iconCodePoint,
                                fontFamily: account.iconFamily,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: nameTextController,
                            decoration: InputDecoration(
                              labelText: tr("name"),
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.length <= 0) {
                                return tr("name must not be empty");
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 70),
                        Expanded(
                          child: TextFormField(
                            controller: balanceTextController,
                            decoration: InputDecoration(
                              labelText: tr("balance"),
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              try {
                                double.tryParse(value);
                              } catch (e) {
                                dPrint(e.toString());
                                return tr("value must be a number");
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    IconPicker(
                      selectedIcon: Icon(
                        IconData(
                          account.iconCodePoint,
                          fontFamily: account.iconFamily,
                        ),
                      ),
                      onIconSelected: (icon) {
                        setState(() {
                          account.iconCodePoint = icon.icon.codePoint;
                          account.iconFamily = icon.icon.fontFamily;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          account.name = nameTextController.text;
                          account.balance = double.parse(balanceTextController.text);

                          if (widget.accountToEdit != null) {
                            BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(account));
                            BlocProvider.of<TransactionsBloc>(context)
                                .add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now())));
                          } else {
                            BlocProvider.of<AccountsBloc>(context).add(AddAccountEvent(account));
                          }
                          BlocProvider.of<AccountsBloc>(context).add(GetAccountsEvent());
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Center(
                          child: Text(
                            tr("save"),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.pageMarginVert),
            ],
          ),
        ),
      ),
    );
  }
}
