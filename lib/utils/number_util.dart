import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class NumberUtil {
  static String doubleToString(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  static String getMathInput(String mathExp, String inputChar) {
    if (mathExp == "0.00") mathExp = "";

    RegExp exp = new RegExp(r"[^+-]+|[+-]");
    Iterable<Match> matches = exp.allMatches(mathExp);
    String lastExp = "";

    if (matches.isNotEmpty) {
      // matches.forEach((m) => print(m.group(0)));
      lastExp = matches.last.group(0);
      // dPrint(lastExp);
    }

    if ("0123456789".contains(inputChar)) {
      if (mathExp == "0") mathExp = "";
      if ((lastExp.contains(".") && lastExp.split(".").last.length < 2) ||
          (!lastExp.contains(".") && lastExp.length < 12) ||
          mathExp == "") {
        mathExp += inputChar;
      }
    } else if (mathExp.length > 0 &&
        "+-".contains(inputChar) &&
        !"+-.".contains(mathExp[mathExp.length - 1])) {
      mathExp += inputChar;
    } else if (inputChar == "." && !lastExp.contains(inputChar)) {
      mathExp += inputChar;
    } else if (inputChar == "del" && mathExp.length > 0) {
      mathExp = mathExp.substring(0, mathExp.length - 1);
      if (mathExp.length == 0) mathExp = "0.00";
    } else if (inputChar == "C") {
      mathExp = "0.00";
    }

    if (mathExp == "") mathExp = "0.00";

    return mathExp;
  }

  static double evaluate(String tokens) {
    if (tokens.length > 0) {
      String lastChar = tokens[tokens.length - 1];
      if ("+-.".contains(lastChar))
        tokens = tokens.substring(0, tokens.length - 1);

      RegExp exp = new RegExp(r"[^+-]+|[+-]");
      Iterable<Match> matches = exp.allMatches(tokens);

      Queue<double> values = QueueList();
      Queue<String> ops = QueueList();

      for (int i = matches.length - 1; i >= 0; i--) {
        String curr = matches.elementAt(i).group(0);
        if ("+-".contains(curr)) {
          ops.addLast(curr);
        } else {
          values.addLast(double.tryParse(curr));
        }
      }

      while (ops.isNotEmpty) {
        String op = ops.last;
        double leftNum = values.last;
        values.removeLast();
        double rightNum = values.last;
        values.removeLast();
        switch (op) {
          case "+":
            values.addLast(leftNum + rightNum);
            break;
          case "-":
            values.addLast(leftNum - rightNum);
            break;
        }
        ops.removeLast();
      }

      return values.last;
    }
    return 0.0;
  }
}

void dPrint(String s) {
  debugPrint("---------- $s");
}
