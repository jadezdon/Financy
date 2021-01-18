import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final String msg;
  const ErrorContainer({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          msg,
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      ),
    );
  }
}
