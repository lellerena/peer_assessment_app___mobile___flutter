import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/router/app_routes.dart';

import '../controller/auth_controller.dart';
import '../../../courses/ui/pages/list_course_page.dart';
import '../../../auth/domain/usecase/auth_usecase.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController(text: 'admin@example.com');
  final passCtrl  = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    // 👉 Si por hot-reload no está inyectado, créalo on-demand
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(
            AuthController(
              Get.isRegistered<AuthUseCase>()
                  ? Get.find<AuthUseCase>()
                  : AuthUseCase(
                      Get.isRegistered<AuthRepository>()
                          ? Get.find<AuthRepository>()
                          : Get.put(AuthRepository(), permanent: true),
                    ),
            ),
            permanent: true,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passCtrl,  decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: auth.loading.value ? null : () async {
                try {
    final ok = await auth.signIn(emailCtrl.text.trim(), passCtrl.text);

    if (!mounted) return; // evita usar context si el widget ya no está

    if (ok) {
      Get.offAllNamed(Routes.userCourses);  // 👈 sin paréntesis
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas')),
      );
    }
  } catch (e, st) {
                  debugPrint('LOGIN ERROR: $e\n$st');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al iniciar sesión')),
                    );
                  }
                }
              },
              child: Text(auth.loading.value ? 'Entrando…' : 'Entrar'),
            )),
          ],
        ),
      ),
    );
  }
}
