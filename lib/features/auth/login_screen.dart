import 'package:flutter/material.dart';

import '../../core/services/auth_repository_provider.dart'; // expone "authRepository"
import '../../core/usecases/auth_usecases.dart';            // SignIn(...)
import '../categories/category_crud_screen.dart';          // a dónde vamos tras login
import '../courses/courses_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer el texto que escribe el usuario
  final emailCtrl = TextEditingController(text: 'admin@example.com'); // demo
  final passCtrl  = TextEditingController(text: '123456');            // demo

  // Caso de uso con el repositorio que definimos antes
  final signIn = SignIn(authRepository);

  bool loading = false; // para deshabilitar botón mientras “piensa”

  void _doLogin() async {
    setState(() => loading = true);

    final email = emailCtrl.text.trim();
    final pass  = passCtrl.text;

    // Llama a la capa de dominio → repositorio (lista en memoria)
    final user = signIn(email, pass);

    setState(() => loading = false);

    if (user != null) {
      // Navega y reemplaza (para que no vuelva con "back")
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CoursesScreen()),
      );
    } else {
      // Muestra error si credenciales inválidas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // EMAIL
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'tucorreo@ejemplo.com',
              ),
            ),
            const SizedBox(height: 12),

            // PASSWORD
            TextField(
              controller: passCtrl,
              obscureText: true, // oculta la contraseña
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
              onSubmitted: (_) => loading ? null : _doLogin(), // Enter para enviar
            ),
            const SizedBox(height: 24),

            // BOTÓN
            ElevatedButton(
              onPressed: loading ? null : _doLogin,
              child: Text(loading ? 'Entrando…' : 'Entrar'),
            ),

            const SizedBox(height: 8),
            const Text(
              'Demo: admin@example.com / 123456',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
