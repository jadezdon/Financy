import 'package:flutter/material.dart';

import '../config/theme.dart';

class FormDivider extends StatelessWidget {
  const FormDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: AppSize.pageMarginHori,
      endIndent: AppSize.pageMarginHori,
      height: 2.0,
      color: Theme.of(context).dividerColor,
    );
  }
}

class FormChooser extends StatelessWidget {
  final ValueChanged<BuildContext> onTap;
  final VoidCallback onCancelTap;
  final IconData iconData;
  final Text text;
  final bool isChoosen;
  const FormChooser({
    Key key,
    this.onTap,
    this.iconData,
    this.text,
    this.onCancelTap,
    this.isChoosen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(iconData),
            SizedBox(width: 15.0),
            Expanded(child: text),
            if (isChoosen) GestureDetector(child: Icon(Icons.clear), onTap: onCancelTap),
          ],
        ),
      ),
    );
  }
}
