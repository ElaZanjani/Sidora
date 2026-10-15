import 'dart:async';
import 'package:flutter/material.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  Timer? _timer;
  int _kalan = 0;
  bool _gonderildi = false;

  void _sosBasildi() {
    setState(() {
      _kalan = 3;
      _gonderildi = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_kalan <= 1) {
        t.cancel();
        setState(() {
          _kalan = 0;
          _gonderildi = true;
        });
      } else {
        setState(() => _kalan--);
      }
    });
  }

  void _iptal() {
    _timer?.cancel();
    setState(() {
      _kalan = 0;
      _gonderildi = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bekliyor = _kalan > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sidora Güvenlik', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), // Telefon genişliğinde sınırlar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Durum Kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _gonderildi ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _gonderildi ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _gonderildi ? Icons.warning_rounded : Icons.shield_rounded,
                        color: _gonderildi ? Colors.red : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _gonderildi ? 'Acil Durum Bildirildi!' : 'Sistem Aktif & Güvende',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _gonderildi ? Colors.red.shade900 : Colors.green.shade900,
                            ),
                          ),
                          Text(
                            _gonderildi ? 'Konum ve ses buluta iletildi' : 'Sensörler ve dinleme devrede',
                            style: TextStyle(
                              fontSize: 12,
                              color: _gonderildi ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Büyük SOS Dairesi
                Column(
                  children: [
                    GestureDetector(
                      onTap: bekliyor ? null : _sosBasildi,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bekliyor ? Colors.amber.shade700 : Colors.red.shade600,
                          boxShadow: [
                            BoxShadow(
                              color: (bekliyor ? Colors.amber : Colors.red).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          bekliyor ? '$_kalan' : 'SOS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      bekliyor ? 'Geri sayım sürüyor...' : 'Acil yardım için butona dokunun',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),

                // İptal Butonu Alanı
                SizedBox(
                  height: 50,
                  child: bekliyor
                      ? FilledButton.tonalIcon(
                          onPressed: _iptal,
                          icon: const Icon(Icons.close),
                          label: const Text('Yanlış Alarm - İptal Et'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.red.shade900,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}