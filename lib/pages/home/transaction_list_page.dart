import 'package:Financy/config/route.dart';
import 'package:Financy/widgets/no_data_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ledger_model.dart';
import '../add_ledger_page.dart';
import '../../utils/date_util.dart';
import '../../widgets/money_text.dart';
import '../../widgets/transaction_detail_dialog.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../blocs/transaction/transactions_bloc.dart';
import '../../config/theme.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../widgets/error.dart';

class TransactionListPage extends StatefulWidget {
  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  DateTimeRange currentDateRange;
  bool isShowDaySum = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isShowDaySum = prefs.getBool(Constant.shp_showDaySum);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TransactionsBloc>(context);
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading) {
          // return Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   child: Center(child: CircularProgressIndicator()),
          // );
          return SizedBox.shrink();
        } else if (state is TransactionsLoaded) {
          currentDateRange = state.dateRange;
          return _buildTransactionList(
            context,
            state.transactions,
            state.ledger,
            bloc,
          );
        } else if (state is TransactionsNotLoaded) {
          return ErrorContainer(msg: "Transactions not loaded");
        } else if (state is TransactionsInitial) {
          return SizedBox.shrink();
        }
        return ErrorContainer(msg: "Transactions no state");
      },
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionModel> transactions,
    LedgerModel ledger,
    TransactionsBloc bloc,
  ) {
    double totalIncome = transactions
        .where((e) => e.category.transactionType == TransactionType.INCOME)
        .toList()
        .fold(0.0, (prevSum, element) => prevSum + element.amount);
    double totalExpense = transactions
        .where((e) => e.category.transactionType == TransactionType.EXPENSE)
        .toList()
        .fold(0.0, (prevSum, element) => prevSum + element.amount);

    Map<String, List<TransactionModel>> transactionsByDate = groupBy(
      transactions,
      (element) => DateFormat("yyyy-MM-dd").format(element.date),
    );

    if (transactionsByDate.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, ledger, totalIncome, totalExpense, bloc),
          NoDataContainer(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, ledger, totalIncome, totalExpense, bloc),
        ...transactionsByDate.values.map((e) => _buildTransactionByDay(context, e)).toList(),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LedgerModel ledger,
    double totalIncome,
    double totalExpense,
    TransactionsBloc bloc,
  ) {
    double remainingBudget = (ledger.budget ?? 0) - totalExpense;
    double cardHeight = 80;
    double circleIndicatorRadius = cardHeight + 30;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight * 1.5,
      margin: EdgeInsets.only(bottom: cardHeight / 2 + 10),
      color: Theme.of(context).primaryColorLight,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Positioned(
            left: AppSize.pageMarginHori,
            top: AppSize.pageMarginVert,
            child: InkWell(
              onTap: () {},
              child: Icon(Icons.menu),
            ),
          ),
          Positioned(
            top: AppSize.pageMarginVert,
            right: AppSize.pageMarginHori,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _selectMonth(
                    context,
                    bloc,
                    currentDateRange.start,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.MMMM(context.locale.toString()).format(currentDateRange.start),
                        style: TextStyle(
                          fontSize: AppSize.fontXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(DateFormat("yyyy").format(currentDateRange.start)),
                    ],
                  ),
                ),
                // SizedBox(width: 15),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     InkWell(
                //       child: Icon(Icons.keyboard_arrow_up_outlined),
                //       onTap: () {
                //         bloc.add(GetTransactionsEvent(DateUtil.getCurrentMonth(
                //           DateTime(currentDateRange.start.year,
                //               currentDateRange.start.month - 1, 1),
                //         )));
                //       },
                //     ),
                //     InkWell(
                //       child: Icon(Icons.keyboard_arrow_down_outlined),
                //       onTap: () {
                //         bloc.add(GetTransactionsEvent(DateUtil.getCurrentMonth(
                //           DateTime(currentDateRange.start.year,
                //               currentDateRange.start.month + 1, 1),
                //         )));
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.2 / 2,
            bottom: (-1) * cardHeight / 2,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.borderRadius),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: cardHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr("income")),
                        SizedBox(height: 5),
                        MoneyText(
                          value: totalIncome,
                          transactionType: TransactionType.INCOME,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    SizedBox(width: cardHeight + 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr("expense")),
                        SizedBox(height: 5),
                        MoneyText(
                          value: totalExpense,
                          transactionType: TransactionType.EXPENSE,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: (MediaQuery.of(context).size.width - circleIndicatorRadius) / 2,
            bottom: (-1) * circleIndicatorRadius / 1.87,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AddLedgerPage(ledger: ledger),
                );
              },
              child: CircularPercentIndicator(
                radius: circleIndicatorRadius,
                lineWidth: circleIndicatorRadius * 0.13,
                percent: _getBudgetPercentage(totalExpense, ledger.budget),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr("budget")),
                    SizedBox(height: 5),
                    MoneyText(
                      value: remainingBudget,
                      fontColor: remainingBudget >= 0 ? Theme.of(context).accentColor : AppColor.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                progressColor: remainingBudget >= 0 ? Theme.of(context).primaryColorDark : AppColor.red,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getBudgetPercentage(double totalExpense, double budget) {
    if (totalExpense == 0) return 1;
    if (budget == 0) return 0;
    if (budget - totalExpense <= 0) return 0.0001;
    return (1 - totalExpense / budget);
  }

  Widget _buildTransactionByDay(
    BuildContext context,
    List<TransactionModel> transactionsByDay,
  ) {
    double dayTotalIncome = transactionsByDay
        .where((e) => e.category.transactionType == TransactionType.INCOME)
        .toList()
        .fold(0.0, (prevSum, element) => prevSum + element.amount);
    double dayTotalExpense = transactionsByDay
        .where((e) => e.category.transactionType == TransactionType.EXPENSE)
        .toList()
        .fold(0.0, (prevSum, element) => prevSum + element.amount);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.borderRadius),
              side: BorderSide(
                width: AppSize.borderWidth,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  Text(
                    DateFormat("MM.dd.").format(transactionsByDay.first.date),
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    DateFormat.EEEE(context.locale.toString()).format(transactionsByDay.first.date),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isShowDaySum)
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (dayTotalIncome != 0)
                            Flexible(
                              child: MoneyText(
                                value: dayTotalIncome,
                                transactionType: TransactionType.INCOME,
                              ),
                            ),
                          if (dayTotalExpense != 0) SizedBox(width: 15),
                          if (dayTotalExpense != 0)
                            Flexible(
                              child: MoneyText(
                                value: dayTotalExpense,
                                transactionType: TransactionType.EXPENSE,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          ...transactionsByDay.map((e) => _buildTransactionItem(context, e)).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setState) {
              return TransactionDetailDialog(transaction: transaction);
            },
          ),
        );
      },
      child: Container(
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                IconData(
                  transaction.category.iconCodePoint,
                  fontFamily: transaction.category.iconFamily,
                ),
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Flexible(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.borderRadius),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      transaction.category.transactionType != TransactionType.TRANSFER
                          ? Text(
                              transaction.category.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Row(
                              children: [
                                Text(
                                  transaction.account.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.arrow_right_alt),
                                Text(
                                  transaction.transferAccount.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                      MoneyText(
                        value: transaction.amount,
                        transactionType: transaction.category.transactionType,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth(
    BuildContext context,
    TransactionsBloc bloc,
    DateTime date,
  ) async {
    final picked = await Navigator.pushNamed(
      context,
      AppRoute.pickMonthPage,
      arguments: date,
    );

    if (picked != null && picked is DateTime && (picked.month != date.month || picked.year != date.year)) {
      bloc.add(GetTransactionsEvent(DateUtil.getCurrentMonth(
        DateTime(picked.year, picked.month, 1),
      )));
    }
  }
}
