import 'package:flutter/material.dart';
import 'package:mydairy/app/app.dart';
import 'package:mydairy/app/config/di/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const MyDairyApp());
}
