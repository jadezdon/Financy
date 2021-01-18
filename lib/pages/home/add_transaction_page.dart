import 'dart:io';
import 'dart:math';

import 'package:Financy/config/theme.dart';
import 'package:Financy/data/models/location_model.dart';
import 'package:Financy/utils/data.dart';
import 'package:Financy/widgets/money_text.dart';

import '../../blocs/accounts/accounts_bloc.dart';
import '../../data/models/account_model.dart';
import '../../utils/date_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../blocs/transaction/transactions_bloc.dart';
import '../../config/route.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../utils/number_util.dart';
import '../../widgets/category_list.dart';
import '../../widgets/choose_account_dialog.dart';
import '../../widgets/choose_contact_dialog.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/numpad.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel transactionToEdit;
  AddTransactionPage({this.transactionToEdit});
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> with SingleTickerProviderStateMixin {
  TransactionModel transaction = TransactionModel();
  String moneyValue = "0.00";
  final TextEditingController commentTextController = TextEditingController();
  TabController tabController;
  int selectedTabIndex;
  bool numpadExpanded = true;

  List<Widget> tabs = [
    Tab(child: Text(tr("income"))),
    Tab(child: Text(tr("expense"))),
    Tab(child: Text(tr("transfer"))),
  ];

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {
        if (widget.transactionToEdit != null) {
          if (tabController.index != 2 &&
              widget.transactionToEdit.category.transactionType == TransactionType.TRANSFER) {
            transaction.category = null;
            transaction.account = null;
          } else if (tabController.index == 2 &&
              widget.transactionToEdit.category.transactionType != TransactionType.TRANSFER) {
            transaction.account = null;
          } else {
            transaction.category = widget.transactionToEdit.category;
            transaction.account = widget.transactionToEdit.account;
          }
        } else {
          transaction.category = null;
          transaction.account = null;
        }
        selectedTabIndex = tabController.index;
      });
    });

    transaction.date = DateTime.now();
    if (widget.transactionToEdit != null) {
      transaction = widget.transactionToEdit.clone();
      moneyValue = NumberUtil.doubleToString(transaction.amount);
      switch (widget.transactionToEdit.category.transactionType) {
        case TransactionType.INCOME:
          tabController.index = 0;
          break;
        case TransactionType.EXPENSE:
          tabController.index = 1;
          break;
        case TransactionType.TRANSFER:
          tabController.index = 2;
          break;
      }
    }
    commentTextController.text = widget.transactionToEdit != null ? widget.transactionToEdit.remark : "";
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) => Container(
          padding: MediaQuery.of(context).padding,
          height: max(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    Container(
                      height: 300,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          _buildCategoryTabView(TransactionType.INCOME),
                          _buildCategoryTabView(TransactionType.EXPENSE),
                          _buildTransferTabView(context),
                        ],
                      ),
                    ),
                    FormDivider(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.comment_outlined),
                          SizedBox(width: 15.0),
                          Flexible(
                            child: TextField(
                              controller: commentTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: tr("comment"),
                                hintStyle: GoogleFonts.openSans(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FormDivider(),
                    FormChooser(
                      onTap: (context) => _chooseLocation(context),
                      iconData: Icons.location_on_outlined,
                      text: transaction.location == null
                          ? Text(
                              tr("choose-location"),
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              transaction.location.getAddressString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                      isChoosen: transaction.location != null,
                      onCancelTap: () {
                        setState(() {
                          transaction.location = null;
                        });
                      },
                    ),
                    FormDivider(),
                    FormChooser(
                      onTap: (context) => _chooseContact(context),
                      iconData: Icons.contacts,
                      text: transaction.personName == ""
                          ? Text(
                              tr("choose-person"),
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              transaction.personName,
                              overflow: TextOverflow.ellipsis,
                            ),
                      isChoosen: transaction.personName != "",
                      onCancelTap: () {
                        setState(() {
                          transaction.personName = "";
                        });
                      },
                    ),
                    FormDivider(),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              numpadExpanded = !numpadExpanded;
                            });
                          },
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
                            child: Icon(numpadExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                          ),
                        ),
                      ),
                      if (numpadExpanded) _buildAccountAndCalendarAndPhotoRow(),
                      if (numpadExpanded)
                        NumPad(
                          onButtonPressed: (String value) {
                            String tempValue = moneyValue;

                            if (value == "ok") {
                              _onOkPressed(context);
                            } else {
                              tempValue = NumberUtil.getMathInput(moneyValue, value);
                            }

                            if (tempValue != moneyValue) {
                              setState(() {
                                moneyValue = tempValue;
                                transaction.amount = NumberUtil.evaluate(moneyValue);
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 260.0,
              child: TabBar(
                controller: tabController,
                tabs: tabs,
              ),
            ),
          ),
          Positioned(
            right: 0.0,
            child: IconButton(
              onPressed: () async {
                if (transaction.imgUrl != "") await File(transaction.imgUrl).delete();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icon(Icons.clear),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabView(TransactionType type) {
    return Column(
      children: [
        Flexible(
          child: CategoryList(
            type: type,
            onCategoryPressed: (CategoryModel model) {
              setState(() {
                transaction.category = model;
              });
            },
            selectedCategory: transaction.category,
          ),
        ),
        FormDivider(),
        _buildCategoryAndMoneyRow(),
      ],
    );
  }

  Widget _buildTransferTabView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.borderRadius),
          ),
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.pageMarginHori,
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr("from")),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ChooseAccountDialog(selectedAccount: transaction.account),
                        ).then((value) {
                          if (value != null && value != transaction.account) {
                            if (value == transaction.transferAccount) {
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: Text(tr("transfer accounts cannot be same"))));
                            } else {
                              setState(() {
                                transaction.account = value;
                              });
                            }
                          }
                        });
                      },
                      child: Text(transaction.account == null ? tr("choose-account") : transaction.account.name),
                    ),
                  ],
                ),
                Container(
                  child: SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "\$ $moneyValue",
                      style: TextStyle(fontSize: AppSize.fontXLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Image(
          width: 50,
          height: 50,
          image: AssetImage("assets/images/transfer.png"),
        ),
        SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.borderRadius),
          ),
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.pageMarginHori,
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr("to")),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ChooseAccountDialog(selectedAccount: transaction.transferAccount),
                        ).then((value) {
                          if (value != null && value != transaction.transferAccount) {
                            if (value == transaction.account) {
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: Text(tr("transfer accounts cannot be same"))));
                            } else {
                              setState(() {
                                transaction.transferAccount = value;
                              });
                            }
                          }
                        });
                      },
                      child: Text(transaction.transferAccount == null
                          ? tr("choose-account")
                          : transaction.transferAccount.name),
                    ),
                  ],
                ),
                Container(
                  child: SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "\$ $moneyValue",
                      style: TextStyle(fontSize: AppSize.fontXLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndMoneyRow() {
    Widget categoryWidget = SizedBox.shrink();
    if (transaction.category != null) {
      categoryWidget = Row(
        children: [
          Icon(IconData(
            transaction.category.iconCodePoint,
            fontFamily: transaction.category.iconFamily,
          )),
          SizedBox(width: 15.0),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
            child: Text(transaction.category.name, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              categoryWidget,
              Spacer(),
              MoneyText(value: transaction.amount, fontColor: Colors.grey),
            ],
          ),
          Container(
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Text(
                "\$ $moneyValue",
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAndCalendarAndPhotoRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Row(
        children: [
          if (selectedTabIndex != 2) //* if not in transfer tab
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
              ),
              child: InkWell(
                onTap: () => _chooseAccount(context),
                child: Center(
                  child: Text(
                    transaction.account != null ? transaction.account.name : tr("choose-account"),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
            ),
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Center(child: Text(DateFormat("MM.dd.").format(transaction.date))),
            ),
          ),
          Spacer(),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.add_a_photo_outlined),
                onPressed: () => _getCapturedPicture(context),
              ),
              _buildPhotoBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBadge() {
    if (transaction.imgUrl != null && transaction.imgUrl != "") {
      return Positioned(
        top: 0.0,
        right: 0.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
          alignment: Alignment.center,
          child: Text(
            '1',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await Navigator.pushNamed(
      context,
      AppRoute.pickDatePage,
      arguments: transaction.date,
    );

    if (picked != null && picked != transaction.date) {
      setState(() {
        transaction.date = picked;
      });
    }
  }

  Future<void> _getCapturedPicture(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoute.takePicturePage,
      arguments: transaction.imgUrl,
    );
    dPrint("img url: $result");
    setState(() {
      if (result == null) {
        transaction.imgUrl = "";
      } else {
        transaction.imgUrl = result;
      }
    });
  }

  void _chooseAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChooseAccountDialog(selectedAccount: transaction.account),
    ).then((value) {
      if (value != null && value != transaction.account) {
        setState(() {
          transaction.account = value;
        });
      }
    });
  }

  void _chooseContact(BuildContext context) async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      showDialog(
        context: context,
        builder: (_) => ChooseContactDialog(selectedContactName: transaction.personName),
      ).then((value) {
        if (value != null && value != transaction.personName) {
          setState(() {
            transaction.personName = value;
          });
        }
      });
    } else {
      await Permission.contacts.request();
    }
  }

  Future<void> _chooseLocation(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoute.pickLocationPage,
      arguments: transaction.location,
    );
    dPrint(result.toString());
    if (result != null) {
      setState(() {
        transaction.location = (result as LocationModel);
      });
    }
  }

  void _onOkPressed(BuildContext context) {
    //* if the current tab is not transfer
    if (selectedTabIndex != 2) {
      if (transaction.category == null) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("please select a category"))));
        return;
      }

      if (transaction.account == null) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("please select an account"))));
        return;
      }

      double result = NumberUtil.evaluate(moneyValue);

      if (result == 0) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("value must not be 0"))));
        return;
      }

      transaction.amount = result;
      transaction.remark = commentTextController.text;

      //* update transaction
      if (widget.transactionToEdit != null) {
        BlocProvider.of<TransactionsBloc>(context).add(UpdateTransactionEvent(transaction));

        //* update accounts
        AccountModel account = transaction.account;
        account.balance += (widget.transactionToEdit.category.transactionType == TransactionType.INCOME)
            ? (-1) * widget.transactionToEdit.amount
            : widget.transactionToEdit.amount;
        account.balance += (transaction.category.transactionType == TransactionType.INCOME)
            ? transaction.amount
            : (-1) * transaction.amount;
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(account));
      } else {
        //* save new transaction
        BlocProvider.of<TransactionsBloc>(context).add(AddTransactionEvent(transaction));

        //* update accounts
        AccountModel account = transaction.account;
        if (account.balance == null) account.balance = 0;
        account.balance += (transaction.category.transactionType == TransactionType.INCOME)
            ? transaction.amount
            : (-1) * transaction.amount;
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(account));
      }
    } else {
      if (transaction.account == null) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("please select an account for transfer from"))));
        return;
      }

      if (transaction.transferAccount == null) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("please select an account for transfer to"))));
        return;
      }
      double result = NumberUtil.evaluate(moneyValue);

      if (result == 0) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr("value must not be 0"))));
        return;
      }

      transaction.category = AppData.transferCategory;
      transaction.amount = result;
      transaction.remark = commentTextController.text;

      if (widget.transactionToEdit != null) {
        BlocProvider.of<TransactionsBloc>(context).add(UpdateTransactionEvent(transaction));

        //* update accounts
        transaction.account.balance += widget.transactionToEdit.amount;
        transaction.account.balance -= transaction.amount;
        transaction.transferAccount.balance -= widget.transactionToEdit.amount;
        transaction.transferAccount.balance += transaction.amount;
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(transaction.account));
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(transaction.transferAccount));
      } else {
        //* save new transaction
        BlocProvider.of<TransactionsBloc>(context).add(AddTransactionEvent(transaction));

        //* update accounts
        if (transaction.account.balance == null) transaction.account.balance = 0;
        if (transaction.transferAccount.balance == null) transaction.transferAccount.balance = 0;
        transaction.account.balance -= transaction.amount;
        transaction.transferAccount.balance += transaction.amount;
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(transaction.account));
        BlocProvider.of<AccountsBloc>(context).add(UpdateAccountEvent(transaction.transferAccount));
      }
    }
    BlocProvider.of<TransactionsBloc>(context).add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now())));
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
