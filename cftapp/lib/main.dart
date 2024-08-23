import 'package:cftapp/pantallas/coments.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cftapp/pantallas/calendar_screen.dart';
import 'package:cftapp/pantallas/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa este paquete para formatear la fecha y la hora

void main() {
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  // Método para obtener la fecha y la hora actuales en el formato deseado
  String _getFormattedDateTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    return 'Fecha: ${dateFormat.format(now)}\nHora: ${timeFormat.format(now)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CFTApp'),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Fondo semitransparente
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7), // Fondo del encabezado con opacidad
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CFT de Los Rios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 8), // Espacio entre el texto del encabezado y la fecha/hora
                    Text(
                      _getFormattedDateTime(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white), // Icono blanco
                title: Text('Inicio', style: TextStyle(color: Colors.white)), // Texto blanco
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.date_range, color: Colors.white),
                title: Text('Calendario', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.mode_comment, color: Colors.white),
                title: Text('Comentarios', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              // Puedes agregar más opciones aquí según sea necesario
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cropped-Recurso-2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Informaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mode_comment),
            label: 'Comentarios',
          ),
        ],
      ),
    );
  }
}
