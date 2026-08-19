import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/exceptions/duplicate_check_in_exception.dart';

abstract interface class CheckInRepository {
  Stream<List<CheckIn>> watchCheckIns(String sessionId);

  Future<CheckIn?> getCurrentUserCheckIn({
    required String sessionId,
    required String userId,
  });

  /// Throws [DuplicateCheckInException] when the same user already has a
  /// check-in for the session.
  Future<CheckIn> submitCheckIn(CheckIn checkIn);
}
