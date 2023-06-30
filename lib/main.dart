import 'package:flutter/material.dart';
import 'package:image_compressor_frontend/providers/image_provider.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter ML Image Compression',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: ChangeNotifierProvider<AppImageProvider>(
          create: (BuildContext context) {
            return AppImageProvider();
          },
          builder: (context, child) {
            return const HomePage();
          },
        ));
  }
}
