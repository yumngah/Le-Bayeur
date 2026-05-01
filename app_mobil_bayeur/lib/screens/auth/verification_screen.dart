import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:app_mobil_bayeur/providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String type; // 'email' or 'phone'
  
  const VerificationScreen({super.key, required this.type});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late Timer _timer;
  int _start = 600; // 10 minutes in seconds
  final bool _canResend = false;
  final int _resendDelay = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Vérification ${widget.type == 'email' ? 'Email' : 'Mobile'}",
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              "Nous avons envoyé un code à 6 chiffres à votre ${widget.type == 'email' ? 'adresse email' : 'numéro de téléphone'}.",
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: Colors.blue)),
              ),
              onCompleted: (pin) {
                if (widget.type == 'email') {
                  ref.read(authProvider.notifier).verifyEmail(pin);
                }
              },
            ),

            const SizedBox(height: 32),
            Text(
              "Le code expire dans $_timerText",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w600),
            ),
            
            const Spacer(),
            
            TextButton(
              onPressed: _canResend ? () {} : null,
              child: Text(
                _canResend ? "Renvoyer le code" : "Renvoyer dans ${_resendDelay}s",
                style: GoogleFonts.inter(color: _canResend ? Colors.blue : Colors.grey),
              ),
            ),

            ElevatedButton(
              onPressed: () {}, // Handled by pinput onCompleted
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
