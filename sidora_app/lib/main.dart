import 'package:flutter/material.dart';
import 'sos_page.dart';
import 'contacts_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sidora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          scaffoldBackgroundColor: const EdgeInsets.all(0).resolve(null) == null ? Colors.grey.shade50 : null,
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
    ContactsPage(),
    Center(child: Text('Harita (Seviye 2)', style: TextStyle(color: Colors.grey))),
    Center(child: Text('Geçmiş Kayıtlar (Seviye 2)', style: TextStyle(color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.security), label: 'Güvenlik'),
            NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'Kişiler'),
            NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Harita'),
            NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Geçmiş'),
          ],
        ),
      );
}