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
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFC5A059),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SİDORA',
              style: TextStyle(
                color: Color(0xFF0D3B2E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimal Durum Kapsülü
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _gonderildi
                          ? const Color(0xFFB33939).withOpacity(0.3)
                          : const Color(0xFF0D3B2E).withOpacity(0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _gonderildi ? const Color(0xFFB33939) : const Color(0xFF2E8B57),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _gonderildi ? 'Kritik Durum Tetiklendi' : 'Korumalı • Otonom Dinleme',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          color: _gonderildi ? const Color(0xFFB33939) : const Color(0xFF2C3E35),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lüks Squircle SOS Butonu
                GestureDetector(
                  onTap: bekliyor ? null : _sosBasildi,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      // Squircle (Yumuşak modern dikdörtgen-oval form)
                      borderRadius: BorderRadius.circular(bekliyor ? 60 : 48),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: bekliyor
                            ? [const Color(0xFFC5A059), const Color(0xFF9E7830)]
                            : _gonderildi
                                ? [const Color(0xFF8B0000), const Color(0xFF5A0000)]
                                : [const Color(0xFF0D3B2E), const Color(0xFF144D3D)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (bekliyor
                                  ? const Color(0xFFC5A059)
                                  : _gonderildi
                                      ? const Color(0xFF8B0000)
                                      : const Color(0xFF0D3B2E))
                              .withOpacity(0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFC5A059).withOpacity(bekliyor ? 0.8 : 0.25),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bekliyor ? '$_kalan' : 'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: bekliyor ? 54 : 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: bekliyor ? 0 : 5,
                          ),
                        ),
                        if (!bekliyor)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Container(
                              width: 24,
                              height: 1.5,
                              color: const Color(0xFFC5A059).withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // İptal Butonu ve Alt Açıklama
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      child: bekliyor
                          ? TextButton.icon(
                              onPressed: _iptal,
                              icon: const Icon(Icons.close, size: 16, color: Color(0xFF8A3B3B)),
                              label: const Text(
                                'İptal Et (Yanlış Alarm)',
                                style: TextStyle(
                                  color: Color(0xFF8A3B3B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                backgroundColor: const Color(0xFFFBECEC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Butona basarak veya anahtar kelimeyle tetiklenir',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A9A93),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}