import 'package:flutter/material.dart';
import 'sos_page.dart';
import 'contacts_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F8), // Çok ferah, hafif yeşil-gri mermer alt tonu
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B2E), // Derin Zümrüt Yeşili
          primary: const Color(0xFF0D3B2E),
          secondary: const Color(0xFFC5A059), // Mat Altın / Şampanya Vurgusu
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeShell(),
    );
  }
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
    Center(
      child: Text(
        'Canlı Güzergah & Harita',
        style: TextStyle(color: Color(0xFF8A9A93), fontSize: 13, letterSpacing: 0.5),
      ),
    ),
    Center(
      child: Text(
        'Adli Kayıtlar & Kanıt Zinciri',
        style: TextStyle(color: Color(0xFF8A9A93), fontSize: 13, letterSpacing: 0.5),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.04), width: 1)),
        ),
        child: NavigationBar(
          height: 64,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE8F1EC),
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined, size: 21, color: Color(0xFF5A6E65)),
              selectedIcon: Icon(Icons.shield, size: 21, color: Color(0xFF0D3B2E)),
              label: 'Kalkan',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline, size: 21, color: Color(0xFF5A6E65)),
              selectedIcon: Icon(Icons.people, size: 21, color: Color(0xFF0D3B2E)),
              label: 'Kişiler',
            ),
            NavigationDestination(
              icon: Icon(Icons.near_me_outlined, size: 21, color: Color(0xFF5A6E65)),
              selectedIcon: Icon(Icons.near_me, size: 21, color: Color(0xFF0D3B2E)),
              label: 'Konum',
            ),
            NavigationDestination(
              icon: Icon(Icons.fingerprint, size: 21, color: Color(0xFF5A6E65)),
              selectedIcon: Icon(Icons.fingerprint, size: 21, color: Color(0xFF0D3B2E)),
              label: 'Mühür',
            ),
          ],
        ),
      ),
    );
  }
}