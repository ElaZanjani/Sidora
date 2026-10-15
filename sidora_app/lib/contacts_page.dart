import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Map<String, String>> _kisiler = [
    {'isim': 'Anne', 'telefon': '+90 555 123 4567', 'oncelik': '1. Öncelik'},
    {'isim': 'Baba', 'telefon': '+90 555 987 6543', 'oncelik': '2. Öncelik'},
    {'isim': 'Kardeş', 'telefon': '+90 555 456 7890', 'oncelik': '3. Öncelik'},
  ];

  void _kisiEkleDialog() {
    final isimController = TextEditingController();
    final telController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Acil Kişi Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: isimController,
              decoration: const InputDecoration(labelText: 'Yakınlık / İsim (Örn: Teyze)'),
            ),
            TextField(
              controller: telController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefon Numarası'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              if (isimController.text.isNotEmpty && telController.text.isNotEmpty) {
                setState(() {
                  _kisiler.add({
                    'isim': isimController.text,
                    'telefon': telController.text,
                    'oncelik': '${_kisiler.length + 1}. Öncelik',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _kisiSil(int index) {
    setState(() {
      _kisiler.removeAt(index);
      // Öncelik numaralarını yeniden güncelle
      for (int i = 0; i < _kisiler.length; i++) {
        _kisiler[i]['oncelik'] = '${i + 1}. Öncelik';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acil Durum Kişileri', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.indigo),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'SOS tetiklendiğinde konum ve kanıt zinciri sırayla bu kişilere SMS ve arama ile iletilir.',
                        style: TextStyle(fontSize: 13, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _kisiler.isEmpty
                    ? const Center(child: Text('Henüz acil durum kişisi eklenmedi.'))
                    : ListView.builder(
                        itemCount: _kisiler.length,
                        itemBuilder: (context, index) {
                          final kisi = _kisiler[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Icon(Icons.person, color: Colors.indigo.shade900),
                              ),
                              title: Text(kisi['isim']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(kisi['telefon']!),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      kisi['oncelik']!,
                                      style: TextStyle(fontSize: 11, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        icon: const Icon(Icons.person_add),
        label: const Text('Kişi Ekle'),
      ),
    );
  }
}