import 'package:flutter/material.dart';
import 'sos_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sidora',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const HomeShell(),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [
    SosPage(),
    Center(child: Text('Kişiler')),
    Center(child: Text('Harita')),
    Center(child: Text('Geçmiş')),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Ana'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Kişiler'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Harita'),
            NavigationDestination(icon: Icon(Icons.history), label: 'Geçmiş'),
          ],
        ),
      );
}