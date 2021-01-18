import 'package:Financy/config/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PickDatePage extends StatefulWidget {
  final DateTime initialDate;
  const PickDatePage({Key key, this.initialDate}) : super(key: key);

  @override
  _PickDatePageState createState() => _PickDatePageState();
}

class _PickDatePageState extends State<PickDatePage> {
  CalendarController calendarController;
  DateTime initialDate;

  @override
  void initState() {
    super.initState();
    calendarController = CalendarController();
    initialDate = widget.initialDate;
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
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
              TableCalendar(
                locale: context.locale.toLanguageTag(),
                calendarController: calendarController,
                initialSelectedDay: initialDate,
                initialCalendarFormat: CalendarFormat.month,
                availableCalendarFormats: {
                  CalendarFormat.month: "month",
                },
                endDay: DateTime.now(),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  centerHeaderTitle: true,
                  headerMargin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: 10,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayColor: Colors.transparent,
                  todayStyle: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(color: Colors.black),
                  outsideWeekendStyle: TextStyle(color: Colors.grey),
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.grey[700]),
                ),
                builders: CalendarBuilders(
                  selectedDayBuilder: (context, date, events) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.borderRadius),
                          side: BorderSide(
                            color: Theme.of(context).accentColor,
                            width: 2,
                          )),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pop(context, calendarController.selectedDay);
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
