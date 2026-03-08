import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/repositories/shared_preferences_finance_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await SharedPreferencesFinanceRepository.create();
  runApp(CpemApp(repository: repository));
}
