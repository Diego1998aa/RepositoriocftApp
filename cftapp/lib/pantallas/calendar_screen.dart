import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/database_helper.dart';
import '../modelos/event.dart';
import '/widgets/event_tile.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Event>> _events;
  late List<Event> _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<Event> events = await _databaseHelper.getEvents();
    setState(() {
      _events = {};
      for (var event in events) {
        DateTime date = DateTime(event.date.year, event.date.month, event.date.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(event);
      }
      _selectedEvents = _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ?? [];
    });
  }

  void _addNewEvent() async {
    final titleController = TextEditingController();
    int selectedType = 1; // Default type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Evento'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  DropdownButton<int>(
                    value: selectedType,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('Reunión de Delegados (Azul)'),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('Actividades (Naranjo)'),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text('Exámenes (Rojo)'),
                      ),
                      DropdownMenuItem<int>(
                        value: 4,
                        child: Text('Feriado (Morado)'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  Event newEvent = Event(
                    title: titleController.text,
                    type: selectedType,
                    date: _selectedDay,
                  );
                  await _databaseHelper.insertEvent(newEvent);
                  await _loadEvents();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllEvents() async {
    await _databaseHelper.deleteAllEvents();
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllEvents();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            calendarStyle: const CalendarStyle(
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: EventTile(event: event),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
