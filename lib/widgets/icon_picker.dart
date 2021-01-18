import 'package:flutter/material.dart';

import '../utils/data.dart';

class IconPicker extends StatelessWidget {
  final Function(Icon) onIconSelected;
  final Icon selectedIcon;
  const IconPicker({Key key, this.selectedIcon, this.onIconSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: (MediaQuery.of(context).size.width / 60).round(),
        shrinkWrap: true,
        children: List.generate(AppData.iconList.length, (index) {
          return IconButton(
            icon: AppData.iconList[index],
            onPressed: () => onIconSelected(AppData.iconList[index]),
            color: (AppData.iconList[index].icon.codePoint ==
                        selectedIcon.icon.codePoint &&
                    AppData.iconList[index].icon.fontFamily ==
                        selectedIcon.icon.fontFamily)
                ? Theme.of(context).accentColor
                : Colors.grey,
          );
        }),
      ),
    );
  }
}
