// ignore_for_file: deprecated_member_use, unused_field
import 'config.dart';
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
  bool _yukleniyor = false;
  String? _sonHash;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _sosBaslat() {
    setState(() {
      _kalan = 3;
      _gonderildi = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalan > 1) {
        setState(() => _kalan--);
      } else {
        timer.cancel();
        setState(() {
          _kalan = 0;
          _gonderildi = true;
        });
        _kayitBaslatAndYukle();
      }
    });
  }

  void _iptalEt() {
    _timer?.cancel();
    setState(() {
      _kalan = 0;
      _gonderildi = false;
    });
  }

  Future<void> _kayitBaslatAndYukle() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/sos_kayit_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _kayitEdiliyor = true;
          _sonKayitYolu = filePath;
        });

        // 3 saniye ortam sesi kaydet
        await Future.delayed(const Duration(seconds: 3));

        final path = await _audioRecorder.stop();
        setState(() => _kayitEdiliyor = false);

        if (path != null) {
          await _sunucuyaYukle(path);
        }
      }
    } catch (e) {
      debugPrint('Kayıt durdurma hatası: $e');
    }
  }

  Future<void> _sunucuyaYukle(String filePath) async {
    setState(() => _yukleniyor = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$kSunucuUrl/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _sonHash = data['sha256'];
        });
      }
    } catch (e) {
      debugPrint('Sunucu yükleme hatası: $e');
    } finally {
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
          'SİDORA AKILLI GÜVENLİK',
          style: TextStyle(color: Color(0xFF0D3B2E), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Durum Rozeti (Düzeltilen Madde #1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B2E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Color(0xFF0D3B2E)),
                    SizedBox(width: 8),
                    Text(
                      'Demo • Manuel Tetikleme',
                      style: TextStyle(color: Color(0xFF0D3B2E), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // SOS Butonu / Sayaç
              GestureDetector(
                onTap: _kalan > 0 ? _iptalEt : _sosBaslat,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kalan > 0
                        ? Colors.amber.shade700
                        : (_gonderildi ? Colors.green.shade700 : const Color(0xFF0D3B2E)),
                    boxShadow: [
                      BoxShadow(
                        color: (_kalan > 0 ? Colors.amber : const Color(0xFF0D3B2E)).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _kalan > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$_kalan', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
                              const Text('İPTAL İÇİN DOKUN', style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1)),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_gonderildi ? Icons.check_circle_outline : Icons.touch_app, size: 48, color: Colors.white),
                              const SizedBox(height: 8),
                              Text(
                                _gonderildi ? 'SİNYAL İLETİLDİ' : 'SOS',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tetikleme Açıklaması (Düzeltilen Madde #2)
              const Text(
                'Butona basılınca tetiklenir (anahtar kelime tespiti geliştiriliyor)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF5A6E65), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 12),

              // Alt Bilgi Notu (Düzeltilen Madde #4)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Color(0xFF0D3B2E)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Acil durum kişileri (bildirim özelliği geliştirme aşamasında)',
                        style: TextStyle(fontSize: 11, color: Color(0xFF7A8D85)),
                      ),
                    ),
                  ],
                ),
              ),

              if (_yukleniyor) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],

              if (_sonHash != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Kanıt Mühür Hash: ${_sonHash!.substring(0, 16)}...',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.green),
                ),
              ],
            ],
          ),
        ),
      );
  }
}