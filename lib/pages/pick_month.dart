import 'package:Financy/config/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PickMonthPage extends StatefulWidget {
  final DateTime initialDate;
  PickMonthPage({Key key, this.initialDate}) : super(key: key);

  @override
  _PickMonthPageState createState() => _PickMonthPageState();
}

class _PickMonthPageState extends State<PickMonthPage> {
  DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: AppSize.pageMarginHori,
          right: AppSize.pageMarginHori,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: AppSize.pageMarginVert),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, null);
                      },
                      child: Icon(Icons.clear_outlined),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = DateTime(selectedDate.year - 1, selectedDate.month);
                      });
                    },
                    child: Icon(Icons.chevron_left),
                  ),
                  SizedBox(width: 20),
                  Text(
                    selectedDate.year.toString(),
                    style: TextStyle(fontSize: AppSize.fontXLarge, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = DateTime(selectedDate.year + 1, selectedDate.month);
                      });
                    },
                    child: Icon(Icons.chevron_right),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
                child: GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: (MediaQuery.of(context).size.width / 100).round(),
                  shrinkWrap: true,
                  children: List.generate(DateTime.monthsPerYear, (index) {
                    if (index + 1 == selectedDate.month) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.borderRadius),
                          side: BorderSide(
                            color: Theme.of(context).accentColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat.MMM(context.locale.toString()).format(
                              DateTime(selectedDate.year, index + 1),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedDate = DateTime(selectedDate.year, index + 1);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Center(
                          child: Text(
                            DateFormat.MMM(context.locale.toString()).format(
                              DateTime(selectedDate.year, index + 1),
                            ),
                            style: TextStyle(
                              color:
                                  selectedDate.year == widget.initialDate.year && index + 1 == widget.initialDate.month
                                      ? Theme.of(context).accentColor
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.pop(context, selectedDate);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Text(
                      tr("select"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
