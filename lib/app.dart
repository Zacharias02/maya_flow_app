import 'package:flutter/material.dart';

import 'features/chat/chat_page.dart';

class MayaFlowApp extends StatelessWidget {
  const MayaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MayaFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A651), // Maya green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}
