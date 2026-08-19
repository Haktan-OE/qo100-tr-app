import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/features/participation/domain/services/check_in_factory.dart';

final checkInFactoryProvider = Provider<CheckInFactory>(
  (ref) => CheckInFactory(),
);
