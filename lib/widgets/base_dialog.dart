import '../config/theme.dart';
import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final Widget contentWidget;
  final Widget titleWidget;
  const BaseDialog({Key key, this.contentWidget, this.titleWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titleWidget != null ? titleWidget : SizedBox.shrink(),
          SizedBox(width: 10),
          InkWell(
            child: Icon(Icons.clear),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori, vertical: 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.borderRadius),
          ),
          child: SingleChildScrollView(
            child: contentWidget,
          ),
        )
      ],
    );
  }
}
