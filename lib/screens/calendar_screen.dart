import 'package:flutter/material.dart';
import 'package:mis_lab3/kolokvium.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  var elements = [];
  var _selectedEvents = [];
  List<Widget> kolokviumi = [];

  bool equal(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget getEvents() {
    if (_selectedEvents.isEmpty) {
      return const Center(
          child: Text(
        "Немате колоквиуми на овој датум",
        style: TextStyle(fontSize: 20),
      ));
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _selectedEvents.length,
          itemBuilder: (contx, index) {
            return Kolokvium(
                _selectedEvents[index]['courseName'] as String,
                _selectedEvents[index]['date'] as String,
                _selectedEvents[index]['time'] as String,
                Theme.of(contx).primaryColor);
          },
        ),
      );
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    List<Map<String, dynamic>> ret = [];

    for (var elem in elements) {
      if (equal(DateTime.parse(elem['date']), day)) {
        ret.add(elem);
      }
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    elements = ModalRoute.of(context)!.settings.arguments
        as List<Map<String, dynamic>>;
    _selectedEvents = _getEventsForDay(_focusedDay);

    return Scaffold(
        appBar: AppBar(
          title: const Text('LAB 04'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  _onDaySelected(selectedDay, focusedDay);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
              ),
              getEvents()
            ],
          ),
        ));
  }
}
