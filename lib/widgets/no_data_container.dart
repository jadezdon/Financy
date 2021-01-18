import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoDataContainer extends StatelessWidget {
  const NoDataContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        children: [
          SizedBox(height: 100),
          Image.asset(
            "assets/images/nodata.png",
            width: 100,
            height: 100,
          ),
          SizedBox(height: 20),
          Text(tr("no data available")),
        ],
      )),
    );
  }
}
