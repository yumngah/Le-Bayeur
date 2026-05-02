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
      height: 64,
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1C1E)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        leading: const BackButton(color: Colors.black)
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Vérification ${widget.type == 'email' ? 'Email' : 'Mobile'}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28, 
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Nous avons envoyé un code à 6 chiffres à votre ${widget.type == 'email' ? 'adresse email' : 'numéro de téléphone'}.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, 
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.blue[600]!, width: 2),
                      color: Colors.white,
                    ),
                  ),
                  onCompleted: (pin) {
                    if (widget.type == 'email') {
                      ref.read(authProvider.notifier).verifyEmail(pin);
                    }
                  },
                ),
              ),

              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Le code expire dans $_timerText",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, 
                        color: Colors.blue[700], 
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              TextButton(
                onPressed: _canResend ? () {} : null,
                style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: Text(
                  _canResend ? "Renvoyer le code" : "Renvoyer dans ${_resendDelay}s",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: _canResend ? Colors.blue[600] : Colors.grey[400],
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {}, // Handled by pinput onCompleted
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  "Continuer", 
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
