import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';
import 'package:maya_flow_app/firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = configureLogging(level: Level.ALL);
  logger.onRecord.listen((r) => debugPrint('${r.loggerName}: ${r.message}'));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MayaFlowApp());
}
