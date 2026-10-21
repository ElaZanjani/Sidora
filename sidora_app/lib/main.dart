// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sos_page.dart';
import 'contacts_page.dart';

void main() {
  runApp(const SidoraApp());
}

class SidoraApp extends StatelessWidget {
  const SidoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        fontFamily: 'SF Pro Display',
      ),
      home: const AnaEkrani(),
    );
  }
}

class AnaEkrani extends StatefulWidget {
  const AnaEkrani({super.key});

  @override
  State<AnaEkrani> createState() => _AnaEkraniState();
}

class _AnaEkraniState extends State<AnaEkrani> {
  int _seciliIndeks = 0;

  final List<Widget> _sayfalar = [
    const SosPage(),
    const ContactsPage(),
    const MapPage(),
    const SealPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _seciliIndeks,
        children: _sayfalar,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _seciliIndeks,
          onTap: (index) => setState(() => _seciliIndeks = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0D3B2E),
          unselectedItemColor: const Color(0xFFA5B2AC),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined, size: 22),
              activeIcon: Icon(Icons.shield, size: 22),
              label: 'Kalkan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 22),
              activeIcon: Icon(Icons.people, size: 22),
              label: 'Kişiler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.near_me_outlined, size: 22),
              activeIcon: Icon(Icons.near_me, size: 22),
              label: 'Konum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint, size: 22),
              activeIcon: Icon(Icons.fingerprint, size: 22),
              label: 'Mühür',
            ),
          ],
        ),
      ),
    );
  }
}

// Konum Taslak Sayfası
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CANLI KONUM & RADAR',
          style: TextStyle(color: Color(0xFF0D3B2E), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: const Color(0xFF0D3B2E).withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Telefon GPS Bağlantısı Aktif',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E2D27)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Acil durumda konum verisi anlık mühürlenir.',
              style: TextStyle(fontSize: 12, color: Color(0xFF7A8D85)),
            ),
          ],
        ),
      ),
    );
  }
}

// Mühür (Olay Geçmişi ve Adli Hash Zinciri) Sayfası
class SealPage extends StatefulWidget {
  const SealPage({super.key});

  @override
  State<SealPage> createState() => _SealPageState();
}

class _SealPageState extends State<SealPage> {
  List<dynamic> _olaylar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _olaylariGetir();
  }

  Future<void> _olaylariGetir() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/events'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _olaylar = data['olaylar'];
          _yukleniyor = false;
        });
      }
    } catch (e) {
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ADLİ KANIT MÜHÜRÜ',
          style: TextStyle(color: Color(0xFF0D3B2E), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D3B2E), size: 20),
            onPressed: () {
              setState(() => _yukleniyor = true);
              _olaylariGetir();
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _yukleniyor
              ? const Center(child: CircularProgressIndicator())
              : _olaylar.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz mühürlenmiş adli kayıt bulunmuyor.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8A9A93)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _olaylar.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final olay = _olaylar[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2E8B57).withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified, size: 16, color: Color(0xFF2E8B57)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Olay #${olay['id']}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    olay['tarih'] ?? '',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF7A8D85)),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Text(
                                'Dosya: ${olay['dosya_adi']}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E2D27)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SHA-256: ${olay['sha256']}',
                                style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: Color(0xFF5A6E65)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Zincir Hash: ${olay['zincir_hash']}',
                                style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: Color(0xFF9E7830)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}