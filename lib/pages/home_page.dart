import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_compressor_frontend/pages/home_page/components/image_compression_section.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../providers/image_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Placeholder(),
          ),
          Expanded(
            flex: 4,
            child: ImageCompressionSection(),
          ),
        ],
      ),
    );
  }
}

