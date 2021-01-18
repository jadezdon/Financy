import 'dart:math';

import 'package:flutter/material.dart';

import '../config/theme.dart';

class NumPad extends StatelessWidget {
  final Function(String) onButtonPressed;

  NumPad({this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Table(
        border: TableBorder.all(
          color: Colors.grey[300],
          width: 2.0,
          style: BorderStyle.solid,
        ),
        children: [
          TableRow(
            children: [
              NumPadButton(
                strValue: "7",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "8",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "9",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "del",
                iconData: Icons.backspace_outlined,
                onButtonPressed: onButtonPressed,
                buttonColor: AppColor.red,
              ),
            ],
          ),
          TableRow(
            children: [
              NumPadButton(
                strValue: "4",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "5",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "6",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "+",
                iconData: Icons.add,
                onButtonPressed: onButtonPressed,
              ),
            ],
          ),
          TableRow(
            children: [
              NumPadButton(
                strValue: "1",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "2",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "3",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "-",
                iconData: Icons.remove,
                onButtonPressed: onButtonPressed,
              ),
            ],
          ),
          TableRow(
            children: [
              NumPadButton(
                strValue: ".",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "0",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "C",
                onButtonPressed: onButtonPressed,
              ),
              NumPadButton(
                strValue: "ok",
                iconData: Icons.check,
                buttonColor: Colors.green[300],
                onButtonPressed: onButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NumPadButton extends StatelessWidget {
  final IconData iconData;
  final String strValue;
  final Color buttonColor;
  final Function(String) onButtonPressed;

  NumPadButton({
    this.iconData,
    this.strValue,
    this.buttonColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(
        MediaQuery.of(context).size.height * 0.08,
        MediaQuery.of(context).size.width * 0.08,
      ),
      child: FlatButton(
        color: buttonColor ?? Colors.grey[200],
        child: iconData != null
            ? Icon(iconData)
            : Text(
                strValue,
                style: Theme.of(context).textTheme.headline2,
              ),
        onPressed: () {
          onButtonPressed(strValue);
        },
      ),
    );
  }
}
