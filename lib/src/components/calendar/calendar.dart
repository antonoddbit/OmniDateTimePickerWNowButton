import 'package:flutter/material.dart';
import 'flutter_calendar.dart' as cdp;

class Calendar extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateChanged;
  final bool Function(DateTime)? selectableDayPredicate;

  const Calendar({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.selectableDayPredicate,
  });

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  late cdp.CalendarDatePicker _calendarDatePicker;
  final GlobalKey _calendarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _calendarDatePicker = cdp.CalendarDatePicker(
      initialDate: widget.initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onDateChanged: widget.onDateChanged,
      selectableDayPredicate: widget.selectableDayPredicate,
      key: _calendarKey, // Add a key to access the internal state
    );
  }

  @override
  Widget build(BuildContext context) {
    return _calendarDatePicker;
  }
}
