import 'package:Financy/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/theme.dart';
import '../data/models/category_model.dart';
import '../utils/number_util.dart';

class MoneyText extends StatefulWidget {
  final double value;
  final TransactionType transactionType;
  final FontWeight fontWeight;
  final double fontSize;
  final Color fontColor;
  const MoneyText({
    Key key,
    this.value,
    this.transactionType,
    this.fontWeight,
    this.fontSize,
    this.fontColor,
  }) : super(key: key);

  @override
  _MoneyTextState createState() => _MoneyTextState();
}

class _MoneyTextState extends State<MoneyText> {
  bool isShowDollarSign = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isShowDollarSign = prefs.getBool(Constant.shp_showDollarSign);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Text moneyText;
    switch (widget.transactionType) {
      case TransactionType.EXPENSE:
        moneyText = Text(
          (isShowDollarSign ? "\$" : "") + '${NumberUtil.doubleToString(widget.value ?? 0)}',
          style: TextStyle(
            color: widget.fontColor ?? AppColor.red,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
            fontSize: widget.fontSize ?? Theme.of(context).textTheme.bodyText1.fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        );
        break;
      case TransactionType.INCOME:
        moneyText = Text(
          (isShowDollarSign ? "\$" : "") + '${NumberUtil.doubleToString(widget.value ?? 0)}',
          style: TextStyle(
            color: widget.fontColor ?? AppColor.green,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
            fontSize: widget.fontSize ?? Theme.of(context).textTheme.bodyText1.fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        );
        break;
      case TransactionType.TRANSFER:
        moneyText = Text(
          (isShowDollarSign ? "\$" : "") + '${NumberUtil.doubleToString(widget.value ?? 0)}',
          style: TextStyle(
            color: widget.fontColor ?? Colors.grey[700],
            fontWeight: widget.fontWeight ?? FontWeight.normal,
            fontSize: widget.fontSize ?? Theme.of(context).textTheme.bodyText1.fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        );
        break;
      default:
        moneyText = Text(
          (isShowDollarSign ? "\$" : "") + '${NumberUtil.doubleToString(widget.value ?? 0)}',
          style: TextStyle(
            color: widget.fontColor ?? Colors.black,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
            fontSize: widget.fontSize ?? Theme.of(context).textTheme.bodyText1.fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        );
        break;
    }
    return moneyText;
  }
}
