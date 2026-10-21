import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, String>> _kisiler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kisileriYukle();
  }

  // Kalıcı hafızadan kişileri oku
  Future<void> _kisileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? kisilerString = prefs.getString('sidora_kisiler');

    if (kisilerString != null) {
      final List<dynamic> decoded = jsonDecode(kisilerString);
      setState(() {
        _kisiler = decoded.map((item) => Map<String, String>.from(item)).toList();
        _yukleniyor = false;
      });
    } else {
      // Varsayılan ilk liste
      setState(() {
        _kisiler = [
          {'isim': 'Anne', 'telefon': '+90 555 123 4567', 'oncelik': '1. Derece'},
          {'isim': 'Baba', 'telefon': '+90 555 987 6543', 'oncelik': '2. Derece'},
        ];
        _yukleniyor = false;
      });
      _kisileriKaydet();
    }
  }

  // Kişileri kalıcı hafızaya kaydet
  Future<void> _kisileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sidora_kisiler', jsonEncode(_kisiler));
  }

  void _kisiEkleDialog() {
    final isimController = TextEditingController();
    final telController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Acil Durum Kişisi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: isimController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Kişi / Yakınlık',
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A8D85)),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Telefon Numarası',
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A8D85)),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (isimController.text.isNotEmpty && telController.text.isNotEmpty) {
                setState(() {
                  _kisiler.add({
                    'isim': isimController.text,
                    'telefon': telController.text,
                    'oncelik': '${_kisiler.length + 1}. Derece',
                  });
                });
                _kisileriKaydet();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ekle', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _kisiSil(int index) {
    setState(() {
      _kisiler.removeAt(index);
      for (int i = 0; i < _kisiler.length; i++) {
        _kisiler[i]['oncelik'] = '${i + 1}. Derece';
      }
    });
    _kisileriKaydet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'GÜVENLİK REHBERİ',
          style: TextStyle(
            color: Color(0xFF0D3B2E),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0D3B2E).withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_clock_outlined, size: 16, color: Color(0xFF0D3B2E)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Otonom alarm anında konum ve şifreli ses kaydı öncelik sırasına göre iletilir.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF5A6E65), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _yukleniyor
                    ? const Center(child: CircularProgressIndicator())
                    : _kisiler.isEmpty
                        ? const Center(
                            child: Text(
                              'Kayıtlı kişi bulunmuyor',
                              style: TextStyle(fontSize: 12, color: Color(0xFF8A9A93)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _kisiler.length,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            itemBuilder: (context, index) {
                              final kisi = _kisiler[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.015),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                  leading: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F1EC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.person_outline, size: 18, color: Color(0xFF0D3B2E)),
                                  ),
                                  title: Text(
                                    kisi['isim']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E2D27),
                                    ),
                                  ),
                                  subtitle: Text(
                                    kisi['telefon']!,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF7A8D85)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9F5EC),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFC5A059).withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          kisi['oncelik']!,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            color: Color(0xFF9E7830),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 17, color: Color(0xFFA5B2AC)),
                                        hoverColor: Colors.transparent,
                                        splashRadius: 18,
                                        onPressed: () => _kisiSil(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _kisiEkleDialog,
        elevation: 2,
        backgroundColor: const Color(0xFF0D3B2E),
        icon: const Icon(Icons.add, size: 16, color: Colors.white),
        label: const Text(
          'Kişi Ekle',
          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
    );
  }
}