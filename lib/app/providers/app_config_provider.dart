import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/config/app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
