import 'package:flutter/material.dart';
import 'injection_container.dart' as di;

import 'package:get/get.dart';

// ===== Router (tus archivos nuevos) =====
import 'core/router/app_routes.dart';
import 'core/router/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Assessment App',
      initialRoute: Routes.splash,
      getPages: AppPages.pages, // <- usa tu AppPages
    );
  }
}
