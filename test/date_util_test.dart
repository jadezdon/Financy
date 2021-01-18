import 'package:Financy/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Check dateTime is in range", () {
    DateTime dateTime = DateTime(2021, 1, 13);
    DateTimeRange dateTimeRange = DateTimeRange(
      start: DateTime(2021, 1, 10),
      end: DateTime(2021, 2, 1),
    );

    bool isInRange = DateUtil.isInDataRange(dateTimeRange, dateTime);
    expect(isInRange, true);
  });

  test(
    "Check dateTime is in range (dateTime equals to dateTimeRange.start)",
    () {
      DateTime dateTime = DateTime(2021, 1, 13);
      DateTimeRange dateTimeRange = DateTimeRange(
        start: DateTime(2021, 1, 13),
        end: DateTime(2021, 2, 1),
      );

      bool isInRange = DateUtil.isInDataRange(dateTimeRange, dateTime);
      expect(isInRange, true);
    },
  );

  test(
    "Check dateTime is in range (dateTime equals to dateTimeRange.end)",
    () {
      DateTime dateTime = DateTime(2021, 2, 1);
      DateTimeRange dateTimeRange = DateTimeRange(
        start: DateTime(2021, 1, 13),
        end: DateTime(2021, 2, 1),
      );

      bool isInRange = DateUtil.isInDataRange(dateTimeRange, dateTime);
      expect(isInRange, true);
    },
  );

  test(
    "Check dateTime is out of range (dateTime equals to dateTimeRange.start)",
    () {
      DateTime dateTime = DateTime(2021, 1, 12);
      DateTimeRange dateTimeRange = DateTimeRange(
        start: DateTime(2021, 1, 13),
        end: DateTime(2021, 2, 1),
      );

      bool isInRange = DateUtil.isInDataRange(dateTimeRange, dateTime);
      expect(isInRange, false);
    },
  );
}
