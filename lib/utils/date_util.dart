import 'package:Financy/utils/number_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateUtil {
  static DateTimeRange getCurrentMonth(DateTime currentDate) {
    return DateTimeRange(
      start: DateTime(currentDate.year, currentDate.month, 1),
      end: DateTime(currentDate.year, currentDate.month + 1, 0),
    );
  }

  static bool isInDataRange(DateTimeRange dateRange, DateTime dateTime) {
    return ((dateRange.start.isBefore(dateTime) && dateRange.end.isAfter(dateTime)) ||
        dateRange.start.isAtSameMomentAs(dateTime) ||
        dateRange.end.isAtSameMomentAs(dateTime));
  }

  static int durationInDay(DateTime start, DateTime end) {
    DateTimeRange dateTimeRange = DateTimeRange(start: start, end: end);
    int duration = dateTimeRange.duration.inDays;

    if (DateFormat("yyyy-MM-dd").format(end) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
      duration++;
    }
    return duration;
  }
}
