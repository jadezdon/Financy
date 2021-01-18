import 'package:flutter/material.dart';

class FabBottomAppBarItem {
  IconData iconData;
  String text;
  FabBottomAppBarItem({this.iconData, this.text});
}

class FabBottomAppBar extends StatefulWidget {
  final List<FabBottomAppBarItem> items;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  FabBottomAppBar({
    this.items,
    this.height: 60.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  });

  @override
  _FabBottomAppBarState createState() => _FabBottomAppBarState();
}

class _FabBottomAppBarState extends State<FabBottomAppBar> {
  int _selectedIndex = 0;

  _onTabSelected(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _onTabSelected,
      );
    });
    items.insert(items.length >> 1, _buildMiddleFabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleFabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: widget.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FabBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.iconData,
                  color: color,
                  size: widget.iconSize,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  item.text,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
