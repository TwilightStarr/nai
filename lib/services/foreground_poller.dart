import 'dart:async';

import 'storage_service.dart';
import 'update_checker.dart';

/// Uygulama açıkken (ön planda) tam olarak istenen aralıkla (varsayılan
/// 10 dakika) siteyi kontrol eden zamanlayıcı. Arka plan/kapalıyken bu
/// görevi Android'in izin verdiği asgari periyotla WorkManager üstlenir.
class ForegroundPoller {
  ForegroundPoller({UpdateChecker? checker, StorageService? storage})
      : _checker = checker ?? UpdateChecker(),
        _storage = storage ?? StorageService();

  final UpdateChecker _checker;
  final StorageService _storage;
  Timer? _timer;

  final StreamController<int> _onUpdate = StreamController<int>.broadcast();

  /// Yeni öğe sayısını yayınlayan akış (UI bunu dinleyip listeyi tazeler).
  Stream<int> get onUpdate => _onUpdate.stream;

  Future<void> start() async {
    final minutes = await _storage.getIntervalMinutes();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: minutes), (_) => _tick());
  }

  Future<void> restartWithNewInterval() => start();

  Future<void> checkImmediately() => _tick();

  Future<void> _tick() async {
    final count = await _checker.checkNow();
    if (!_onUpdate.isClosed) {
      _onUpdate.add(count);
    }
  }

  void dispose() {
    _timer?.cancel();
    _onUpdate.close();
    _checker.dispose();
  }
}
