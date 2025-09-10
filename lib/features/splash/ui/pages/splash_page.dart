// lib/features/splash/ui/pages/splash_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/router/app_routes.dart'; // <-- ajusta si tu path es distinto

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int percent = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 25), (t) {
      if (!mounted) return;
      setState(() => percent = (percent + 1).clamp(0, 100));
      if (percent >= 100) {
        t.cancel();
        // Si primero quieres ir al login SIEMPRE:
        Get.offAllNamed(Routes.login);

        // Si más adelante quieres saltarte el login cuando ya haya sesión,
        // aquí podrías revisar tu AuthController y decidir a dónde ir.
        // final auth = Get.find<AuthController>();
        // final logged = auth.currentUser != null;
        // Get.offAllNamed(logged ? Routes.userCourses : Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B2CBF), Color(0xFFFF2768)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.analytics_outlined,
                      size: 64, color: Color(0xFF6A1B9A)),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Peer Assessment App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evaluate • Learn • Grow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: .2,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 36),
                // Barra de carga
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percent / 100.0,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
