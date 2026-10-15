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
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Chip(
            avatar: Icon(
              _gonderildi ? Icons.warning : Icons.check_circle,
              color: _gonderildi ? Colors.red : Colors.green,
            ),
            label: Text(
              _gonderildi ? 'Acil durum bildirildi' : 'Güvende',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: bekliyor ? null : _sosBasildi,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bekliyor ? Colors.orange : Colors.red,
                boxShadow: const [
                  BoxShadow(blurRadius: 24, color: Colors.black26)
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                bekliyor ? '$_kalan' : 'SOS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (bekliyor)
            FilledButton.tonal(
              onPressed: _iptal,
              child: const Text('İptal et'),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}