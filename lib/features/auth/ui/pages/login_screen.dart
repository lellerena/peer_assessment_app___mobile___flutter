import '/features/auth/ui/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../controller/auth_controller.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerEmail = TextEditingController(
    text: 'augustosalazar@uninorte.edu.co',
  );
  final controllerPassword = TextEditingController(text: 'ThePassword1!');
  AuthenticationController authenticationController = Get.find();

  _login(theEmail, thePassword) async {
    logInfo('_login $theEmail $thePassword');
    try {
      await authenticationController.login(theEmail, thePassword);
    } catch (err) {
      Get.snackbar(
        "Login",
        err.toString(),
        icon: const Icon(Icons.person, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Edu Manage',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: controllerEmail,
                        decoration: InputDecoration(
                          hintText: 'correo electrónico@dominio.com',
                          filled: true,
                          fillColor: theme.colorScheme.primaryContainer.withOpacity(.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return 'Ingrese el correo';
                          if (!value.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controllerPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'password',
                          filled: true,
                          fillColor: theme.colorScheme.primaryContainer.withOpacity(.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return 'Ingrese la contraseña';
                          if (value.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                        onFieldSubmitted: (_) async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            await _login(controllerEmail.text, controllerPassword.text);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              await _login(controllerEmail.text, controllerPassword.text);
                            }
                          },
                          child: const Text('Continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Al hacer clic en continuar, aceptas nuestros Términos de servicio y Política de privacidad',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(.6),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text('¿Olvidaste la contraseña?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text('Regístrate'),
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
