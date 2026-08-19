import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_check_in_repository.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/domain/exceptions/duplicate_check_in_exception.dart';
import 'package:qo100_tr/features/participation/domain/repositories/check_in_repository.dart';
import 'package:qo100_tr/features/participation/domain/services/check_in_factory.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_controller.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_flow_state.dart';
import 'package:qo100_tr/features/participation/presentation/providers/check_in_dependencies.dart';
import 'package:qo100_tr/features/participation/presentation/providers/participation_providers.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

void main() {
  test('initializes in idle state with Direkt selected', () async {
    final fixture = FixtureCheckInRepository(checkIns: const []);
    addTearDown(fixture.dispose);
    final harness = await _createHarness(fixture);
    addTearDown(harness.dispose);

    expect(harness.state.status, CheckInStatus.idle);
    expect(harness.state.selectedType, ParticipationType.direct);
  });

  test('submits Direkt and reaches successful state', () async {
    final fixture = FixtureCheckInRepository(checkIns: const []);
    addTearDown(fixture.dispose);
    final harness = await _createHarness(fixture);
    addTearDown(harness.dispose);

    await harness.notifier.submit();

    expect(harness.state.status, CheckInStatus.success);
    expect(harness.state.checkIn?.participationType, ParticipationType.direct);
    expect(harness.state.checkIn?.timestamp, _fixedTime);
  });

  test('submits SWL and reaches successful state', () async {
    final fixture = FixtureCheckInRepository(checkIns: const []);
    addTearDown(fixture.dispose);
    final harness = await _createHarness(fixture);
    addTearDown(harness.dispose);

    harness.notifier.selectType(ParticipationType.swl);
    await harness.notifier.submit();

    expect(harness.state.status, CheckInStatus.success);
    expect(harness.state.checkIn?.participationType, ParticipationType.swl);
  });

  test('exposes submitting before repository completion', () async {
    final repository = _DelayedCheckInRepository();
    final harness = await _createHarness(repository);
    addTearDown(harness.dispose);

    final submission = harness.notifier.submit();

    expect(harness.state.status, CheckInStatus.submitting);
    repository.complete();
    await submission;
    expect(harness.state.status, CheckInStatus.success);
  });

  test('maps duplicate repository error to alreadyCheckedIn', () async {
    final existing = _checkIn(participationType: ParticipationType.swl);
    final repository = _DuplicateOnSubmitRepository(existing);
    final harness = await _createHarness(repository);
    addTearDown(harness.dispose);

    await harness.notifier.submit();

    expect(harness.state.status, CheckInStatus.alreadyCheckedIn);
    expect(harness.state.checkIn, same(existing));
    expect(harness.state.selectedType, ParticipationType.swl);
  });

  test('repeated submission attempts create only one record', () async {
    final repository = _DelayedCheckInRepository();
    final harness = await _createHarness(repository);
    addTearDown(harness.dispose);

    final first = harness.notifier.submit();
    final second = harness.notifier.submit();

    expect(repository.submitCalls, 1);
    repository.complete();
    await Future.wait([first, second]);
    expect(repository.submitCalls, 1);
    expect(harness.state.status, CheckInStatus.success);
  });

  test('detects an existing check-in during initialization', () async {
    final existing = _checkIn();
    final fixture = FixtureCheckInRepository(checkIns: [existing]);
    addTearDown(fixture.dispose);
    final harness = await _createHarness(fixture);
    addTearDown(harness.dispose);

    expect(harness.state.status, CheckInStatus.alreadyCheckedIn);
    expect(harness.state.checkIn, same(existing));
  });

  test('maps a generic repository failure to recoverable error', () async {
    final harness = await _createHarness(_FailingCheckInRepository());
    addTearDown(harness.dispose);

    await harness.notifier.submit();

    expect(harness.state.status, CheckInStatus.error);
    expect(harness.state.canSubmit, isTrue);
    expect(harness.state.errorMessage, contains('yeniden deneyin'));
  });
}

final _fixedTime = DateTime.utc(2026, 8, 23, 18, 30);

final _session = CommunitySession(
  id: 'session-1',
  title: 'Test Oturumu',
  startAt: DateTime.utc(2026, 8, 23, 18),
  frequencyMHz: 12345.678,
  isActive: true,
);

const _profile = UserProfile(
  id: 'user-1',
  callsign: 'TA0TEST',
  name: 'Test Operatörü',
  city: 'Ankara',
  locator: 'KM69',
  role: UserRole.member,
);

CheckInContext get _context =>
    CheckInContext(session: _session, profile: _profile);

CheckIn _checkIn({
  ParticipationType participationType = ParticipationType.direct,
}) {
  return CheckIn(
    id: 'existing-check-in',
    sessionId: _session.id,
    userId: _profile.id,
    callsign: _profile.callsign,
    participationType: participationType,
    timestamp: _fixedTime,
  );
}

Future<_ControllerHarness> _createHarness(CheckInRepository repository) async {
  final container = ProviderContainer.test(
    overrides: [
      checkInRepositoryProvider.overrideWithValue(repository),
      checkInFactoryProvider.overrideWithValue(
        CheckInFactory(
          clock: () => _fixedTime,
          idGenerator: (timestamp) => 'deterministic-check-in',
        ),
      ),
    ],
  );
  final provider = checkInControllerProvider(_context);
  final subscription = container.listen(provider, (previous, next) {});
  await container.read(provider.future);
  return _ControllerHarness(container, provider, subscription);
}

class _ControllerHarness {
  const _ControllerHarness(this.container, this.provider, this.subscription);

  final ProviderContainer container;
  final AsyncNotifierProvider<CheckInController, CheckInFlowState> provider;
  final ProviderSubscription<AsyncValue<CheckInFlowState>> subscription;

  CheckInController get notifier => container.read(provider.notifier);

  CheckInFlowState get state => container.read(provider).requireValue;

  void dispose() {
    subscription.close();
    container.dispose();
  }
}

class _DelayedCheckInRepository implements CheckInRepository {
  final Completer<CheckIn> _completer = Completer<CheckIn>();
  CheckIn? _pending;
  int submitCalls = 0;

  @override
  Future<CheckIn?> getCurrentUserCheckIn({
    required String sessionId,
    required String userId,
  }) async => null;

  @override
  Future<CheckIn> submitCheckIn(CheckIn checkIn) {
    submitCalls++;
    _pending = checkIn;
    return _completer.future;
  }

  @override
  Stream<List<CheckIn>> watchCheckIns(String sessionId) => const Stream.empty();

  void complete() => _completer.complete(_pending);
}

class _DuplicateOnSubmitRepository implements CheckInRepository {
  _DuplicateOnSubmitRepository(this.existing);

  final CheckIn existing;
  bool _submitted = false;

  @override
  Future<CheckIn?> getCurrentUserCheckIn({
    required String sessionId,
    required String userId,
  }) async => _submitted ? existing : null;

  @override
  Future<CheckIn> submitCheckIn(CheckIn checkIn) async {
    _submitted = true;
    throw DuplicateCheckInException(
      sessionId: checkIn.sessionId,
      userId: checkIn.userId,
    );
  }

  @override
  Stream<List<CheckIn>> watchCheckIns(String sessionId) =>
      Stream.value([existing]);
}

class _FailingCheckInRepository implements CheckInRepository {
  @override
  Future<CheckIn?> getCurrentUserCheckIn({
    required String sessionId,
    required String userId,
  }) async => null;

  @override
  Future<CheckIn> submitCheckIn(CheckIn checkIn) {
    throw StateError('fixture failure');
  }

  @override
  Stream<List<CheckIn>> watchCheckIns(String sessionId) => const Stream.empty();
}
