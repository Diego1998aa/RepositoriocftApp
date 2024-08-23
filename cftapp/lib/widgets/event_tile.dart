import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modelos/event.dart';

class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    List<Color> eventColors = [
      Colors.blue, // Reunion de Delegados
      Colors.orange, // Actividades
      Colors.red, // Exámenes
      Colors.purple, // Feriado
    ];

    return ListTile(
      title: Text(event.title),
      subtitle: Text(DateFormat('dd-MM-yyyy').format(event.date)),
      leading: CircleAvatar(
        backgroundColor: eventColors[event.type],
      ),
    );
  }
}
