// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  Timer? _timer;
  int _kalan = 0;
  bool _gonderildi = false;
  
  // Ses Kayıt ve Yükleme Mantığı
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _kayitEdiliyor = false;
  String? _sonKayitYolu;
  String? _sonHash;
  bool _yukleniyor = false;

  Future<void> _kayitBaslat() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/sidora_alarm_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        setState(() {
          _kayitEdiliyor = true;
          _sonKayitYolu = filePath;
          _sonHash = null;
        });
      }
    } catch (e) {
      debugPrint('Kayıt başlatma hatası: $e');
    }
  }

  Future<void> _kayitDurdurAndYukle() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _kayitEdiliyor = false;
        _sonKayitYolu = path;
      });
      debugPrint('Ses kaydı tamamlandı: $path');

      if (path != null) {
        await _sunucuyaYukle(path);
      }
    } catch (e) {
      debugPrint('Kayıt durdurma hatası: $e');
    }
  }

  // FastAPI Sunucusuna /upload isteği gönderir ve SHA-256 hash alır
  Future<void> _sunucuyaYukle(String filePath) async {
    setState(() => _yukleniyor = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _sonHash = data['sha256'];
        });
        debugPrint('Kanıt Hash Mühürü: $_sonHash');
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Sunucuya yükleme bağlantı hatası: $e');
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

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
        _kayitBaslat();
      } else {
        setState(() => _kalan--);
      }
    });
  }

  void _iptal() {
    _timer?.cancel();
    if (_kayitEdiliyor) {
      _kayitDurdurAndYukle();
    }
    setState(() {
      _kalan = 0;
      _gonderildi = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A059).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFC5A059), width: 0.8),
              ),
              child: const Text(
                'DEMO',
                style: TextStyle(
                  color: Color(0xFF9E7830),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
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
                          color: _kayitEdiliyor
                              ? Colors.red
                              : _gonderildi
                                  ? const Color(0xFFB33939)
                                  : const Color(0xFF2E8B57),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _kayitEdiliyor
                            ? 'Ses Kaydı Alınıyor (Ortam Dinlemede)...'
                            : _yukleniyor
                                ? 'Kanıt Sunucuya Yükleniyor...'
                                : _gonderildi
                                    ? 'Kritik Durum Tetiklendi'
                                    : 'Korumalı • Otonom Dinleme',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          color: _kayitEdiliyor
                              ? Colors.red.shade800
                              : _gonderildi
                                  ? const Color(0xFFB33939)
                                  : const Color(0xFF2C3E35),
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: bekliyor ? null : _sosBasildi,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
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

                Column(
                  children: [
                    if (_sonHash != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'SHA-256 Mühür: ${_sonHash!.substring(0, 12)}...',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2E8B57),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 44,
                      child: bekliyor || _kayitEdiliyor
                          ? TextButton.icon(
                              onPressed: _iptal,
                              icon: const Icon(Icons.stop, size: 16, color: Color(0xFF8A3B3B)),
                              label: Text(
                                _kayitEdiliyor ? 'Kaydı Durdur & Mühürle' : 'İptal Et (Yanlış Alarm)',
                                style: const TextStyle(
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






