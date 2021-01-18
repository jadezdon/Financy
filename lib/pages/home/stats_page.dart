import 'dart:math';

import 'package:Financy/blocs/filtered_transactions/filtered_transactions_bloc.dart';
import 'package:Financy/data/models/category_model.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:Financy/widgets/money_text.dart';
import 'package:Financy/widgets/no_data_container.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../config/theme.dart';
import '../../data/models/transaction_model.dart';
import '../../widgets/error.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions;
  DateTimeRange currentDateRange;
  TransactionType currentTransactionType;
  ChartType currentChartType = ChartType.PIE;
  List<PieChartSectionData> pieChartDataList = [];
  List<BarChartGroupData> barChartDataList = [];
  List<CategorySum> categorySumList = [];
  List<CategoryDaySum> categoryDaySumList = [];
  double maxDaySum = 0;
  double totalSum = 0;
  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilteredTransactionsBloc, FilteredTransactionsState>(
      builder: (context, state) {
        if (state is FilteredTransactionsLoading) {
          // return Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   child: Center(child: CircularProgressIndicator()),
          // );
          return SizedBox.shrink();
        } else if (state is FilteredTransactionsLoaded) {
          currentDateRange = state.dateRange;
          currentTransactionType = state.transactionType;
          transactions = state.transactions;
          _initChartDatas(state.transactions);
          return _buildStatsPage(context);
        } else if (state is FilteredTransactionsNotLoaded) {
          return ErrorContainer(msg: "Transactions not loaded");
        } else if (state is FilteredTransactionsInitial) {
          return SizedBox.shrink();
        }
        return ErrorContainer(msg: "Transactions no state");
      },
    );
  }

  void _initChartDatas(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return;

    //* initialize data for PIE chart
    pieChartDataList = [];
    categorySumList = [];
    totalSum = 0;

    Map<CategoryModel, List<TransactionModel>> transactionsByCategory = groupBy(
      transactions,
      (element) => element.category,
    );

    transactionsByCategory.forEach((key, value) {
      double sum = value.fold(0.0, (prevSum, element) => prevSum + element.amount);
      categorySumList.add(CategorySum(key, sum));
      totalSum += sum;
    });

    categorySumList.sort((a, b) {
      double aValue = a.sum;
      double bValue = b.sum;
      return bValue.compareTo(aValue);
    });

    for (int index = 0; index < categorySumList.length; index++) {
      categorySumList[index].percentage = (categorySumList[index].sum / totalSum) * 100;
      categorySumList[index].color = AppColor.colorPalette[index % AppColor.colorPalette.length];
      pieChartDataList.add(
        PieChartSectionData(
          value: categorySumList[index].sum,
          color: categorySumList[index].color,
          showTitle: index == selectedIndex,
          radius: index == selectedIndex
              ? MediaQuery.of(context).size.width * 0.32
              : MediaQuery.of(context).size.width * 0.3,
          title: categorySumList[index].category.name,
          titlePositionPercentageOffset: 0.7,
        ),
      );
    }

    //* initialize data for BAR chart
    barChartDataList = [];
    categoryDaySumList = [];
    maxDaySum = 0;

    Map<String, List<TransactionModel>> transactionsByDay =
        groupBy(transactions, (element) => DateFormat("yyyy-MM-dd").format(element.date));

    transactionsByDay.forEach((key, value) {
      Map<CategoryModel, List<TransactionModel>> transactionsByCategoryAndDay = groupBy(
        value,
        (element) => element.category,
      );
      List<CategorySum> sumListInDay = [];
      double daySum = 0;
      transactionsByCategoryAndDay.forEach((category, transactionList) {
        double sum = transactionList.fold(0.0, (prevSum, element) => prevSum + element.amount);
        Color color = categorySumList.where((element) => element.category == category).first.color;
        sumListInDay.add(CategorySum(category, sum, color: color));
        daySum += sum;
      });
      maxDaySum = max(maxDaySum, daySum);
      sumListInDay.sort((a, b) {
        double aValue = a.sum;
        double bValue = b.sum;
        return bValue.compareTo(aValue);
      });
      categoryDaySumList.add(CategoryDaySum(value.first.date, daySum, sumListInDay));
    });

    categoryDaySumList.sort((a, b) {
      DateTime aDate = a.date;
      DateTime bDate = b.date;
      return aDate.compareTo(bDate);
    });

    for (int i = 0; i < currentDateRange.duration.inDays + 1; i++) {
      DateTime currDate = DateTime(
        currentDateRange.start.year,
        currentDateRange.start.month,
        currentDateRange.start.day + i,
      );

      List<CategoryDaySum> currCategoryDaySums = categoryDaySumList
          .where(
              (element) => DateFormat("yyyy-MM-dd").format(element.date) == DateFormat("yyyy-MM-dd").format(currDate))
          .toList();

      //* if no data at the day
      if (currCategoryDaySums.isEmpty) {
        barChartDataList.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(y: 0, rodStackItems: [])],
        ));
        continue;
      }

      CategoryDaySum currCategoryDaySum = currCategoryDaySums.first;
      double currSum = 0;
      List<BarChartRodStackItem> stackItems = [];
      currCategoryDaySum.categorySums.forEach((element) {
        stackItems.add(BarChartRodStackItem(currSum, currSum + element.sum, element.color));
        currSum += element.sum;
      });
      barChartDataList.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            y: currCategoryDaySum.daySum,
            rodStackItems: stackItems,
            borderRadius: BorderRadius.all(Radius.zero),
          ),
        ],
      ));
    }
  }

  Widget _buildStatsPage(BuildContext context) {
    if (transactions.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          SizedBox(height: 15),
          _buildTabs(context),
          SizedBox(height: 15),
          NoDataContainer(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        SizedBox(height: 15),
        _buildTabs(context),
        SizedBox(height: 15),
        _buildChartContainer(context),
        SizedBox(height: 15),
        Column(
          children: [
            ...categorySumList.map((e) => _buildDataListItem(context, e)).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSize.pageMarginVert,
        horizontal: AppSize.pageMarginHori,
      ),
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).primaryColorLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              BlocProvider.of<FilteredTransactionsBloc>(context).add(GetFilteredTransactionsEvent(
                DateUtil.getCurrentMonth(DateTime(
                  currentDateRange.start.year,
                  currentDateRange.start.month - 1,
                  currentDateRange.start.day,
                )),
                currentTransactionType,
              ));
            },
            child: Icon(Icons.chevron_left),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  DateFormat("yyyy.MM.dd").format(currentDateRange.start),
                  style: TextStyle(
                    fontSize: AppSize.fontLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: AppSize.fontLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat("yyyy.MM.dd").format(currentDateRange.end),
                  style: TextStyle(
                    fontSize: AppSize.fontLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              BlocProvider.of<FilteredTransactionsBloc>(context).add(GetFilteredTransactionsEvent(
                DateUtil.getCurrentMonth(DateTime(
                  currentDateRange.start.year,
                  currentDateRange.start.month + 1,
                  currentDateRange.start.day,
                )),
                currentTransactionType,
              ));
            },
            child: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context) {
    if (transactions.isEmpty) return _buildTabs(context);

    return Column(
      children: [
        currentChartType == ChartType.PIE ? _buildPieChart() : _buildBarChart(),
        SizedBox(height: 15),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    currentChartType = ChartType.PIE;
                  });
                },
                child: Icon(
                  Icons.pie_chart_outline_outlined,
                  color: currentChartType == ChartType.PIE ? Theme.of(context).accentColor : Colors.grey,
                ),
              ),
              VerticalDivider(color: Colors.black),
              InkWell(
                onTap: () {
                  setState(() {
                    currentChartType = ChartType.BAR;
                  });
                },
                child: Icon(
                  Icons.bar_chart_outlined,
                  color: currentChartType == ChartType.BAR ? Theme.of(context).accentColor : Colors.grey,
                ),
              ),
              SizedBox(width: AppSize.pageMarginHori),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.pageMarginHori,
          vertical: AppSize.pageMarginVert,
        ),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Center(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<FilteredTransactionsBloc>(context).add(
                      GetFilteredTransactionsEvent(currentDateRange, TransactionType.INCOME),
                    );
                  },
                  child: Text(
                    tr("income"),
                    style: TextStyle(
                      color: currentTransactionType == TransactionType.INCOME
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Text("|"),
            Flexible(
              flex: 1,
              child: Center(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<FilteredTransactionsBloc>(context).add(
                      GetFilteredTransactionsEvent(currentDateRange, TransactionType.EXPENSE),
                    );
                  },
                  child: Text(
                    tr("expense"),
                    style: TextStyle(
                      color: currentTransactionType == TransactionType.EXPENSE
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Text("|"),
            // Flexible(
            //   flex: 1,
            //   child: Center(
            //     child: InkWell(
            //       onTap: () {
            //         BlocProvider.of<FilteredTransactionsBloc>(context).add(
            //           GetFilteredTransactionsEvent(currentDateRange, null),
            //         );
            //       },
            //       child: Text(
            //         tr("all"),
            //         style: TextStyle(
            //           color: currentTransactionType == null ? Theme.of(context).accentColor : Colors.grey,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.75,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.width * 0.65,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.35),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sections: pieChartDataList,
                    borderData: FlBorderData(show: false),
                    centerSpaceRadius: 0,
                    pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse.touchInput is FlLongPressEnd || pieTouchResponse.touchInput is FlPanEnd) {
                          selectedIndex = -1;
                        } else {
                          selectedIndex = pieTouchResponse.touchedSectionIndex;
                        }
                      });
                    }),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.3),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr("total")),
                    SizedBox(height: 10),
                    MoneyText(
                      value: totalSum,
                      fontSize: AppSize.fontLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: currentDateRange.duration.inDays * 20.0,
          padding: EdgeInsets.only(top: 15),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) => TextStyle(color: Color(0xff939393), fontSize: 10),
                  margin: 10,
                  getTitles: (double value) {
                    return DateTime(
                      currentDateRange.start.year,
                      currentDateRange.start.month,
                      currentDateRange.start.day + value.round(),
                    ).day.toString();
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTextStyles: (value) => TextStyle(color: Color(0xff939393), fontSize: 10),
                  margin: 10,
                  interval: maxDaySum / 10,
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: maxDaySum / 10,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Color(0xffe7e8ec),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              groupsSpace: 10,
              barGroups: barChartDataList,
              minY: 0,
              maxY: maxDaySum * 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataListItem(BuildContext context, CategorySum data) {
    Color color = Colors.transparent;
    if (selectedIndex != null && selectedIndex >= 0 && data == categorySumList[selectedIndex]) {
      color = Theme.of(context).accentColor;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(border: Border.all(color: color)),
          child: Row(
            children: [
              Icon(
                IconData(data.category.iconCodePoint, fontFamily: data.category.iconFamily),
                color: data.color,
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            data.category.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Text(
                            data.percentage.toStringAsFixed(2) + "%",
                            style: TextStyle(color: Colors.grey, fontSize: AppSize.fontSmall),
                          ),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: MoneyText(value: data.sum),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    LinearPercentIndicator(
                      percent: data.percentage / 100,
                      backgroundColor: AppColor.lightgrey,
                      progressColor: data.color,
                      padding: EdgeInsets.zero,
                      animation: true,
                      animationDuration: 1000,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ChartType { PIE, BAR }

class CategorySum {
  CategoryModel category;
  double sum;
  double percentage;
  Color color;

  CategorySum(this.category, this.sum, {this.percentage, this.color});

  @override
  String toString() => "[CategoryData: ${category.name}, $sum, $percentage, $color]";
}

class CategoryDaySum {
  DateTime date;
  List<CategorySum> categorySums;
  double daySum;

  CategoryDaySum(this.date, this.daySum, this.categorySums);
}
