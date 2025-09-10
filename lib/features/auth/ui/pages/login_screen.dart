import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/router/app_routes.dart';

import '../controller/auth_controller.dart';
import '../../../courses/ui/pages/courses_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();

    // Precargar credenciales guardadas
    auth.loadSavedCredentials().then((credentials) {
      if (credentials != null) {
        setState(() {
          emailCtrl.text = credentials['email']!;
          passCtrl.text = credentials['password']!;
          auth.rememberMe = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Recordar sesión'),
              value: auth.rememberMe,
              onChanged: (value) {
                setState(() {
                  auth.rememberMe = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final success = await auth.signIn(
                  emailCtrl.text,
                  passCtrl.text,
                );
                if (success) {
                  Get.offAll(() => const CoursesPage());
                } else {
                  Get.snackbar(
                    'Error',
                    'Credenciales inválidas',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
