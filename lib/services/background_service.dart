import 'package:workmanager/workmanager.dart';

import 'update_checker.dart';

const String kBackgroundTaskName = 'nai_check_updates_task';
const String kBackgroundTaskUniqueName = 'nai_check_updates_unique';

/// WorkManager, arka plan izole'unda (isolate) tetiklendiğinde bu üst düzey
/// fonksiyon çalıştırılır. Android işletim sistemi, pil optimizasyonu
/// nedeniyle periyodik görevler için 15 dakikadan kısa bir aralığa izin
/// vermez; bu yüzden arka plan görevi 15 dakikada bir planlanır. Uygulama
/// ön plandayken (açıkken) ise tam olarak istenen 10 dakikalık aralıkla
/// ayrıca kontrol yapılır (bkz. ForegroundPoller).
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final checker = UpdateChecker();
      await checker.checkNow();
      checker.dispose();
    } catch (_) {
      // Arka planda oluşan hatalar görevi başarısız saymaz; bir sonraki
      // periyotta yeniden denenir.
    }
    return true;
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundDispatcher,
      isInDebugMode: false,
    );
  }

  /// Android'in izin verdiği asgari periyot olan 15 dakikada bir çalışacak
  /// periyodik görevi kaydeder.
  static Future<void> registerPeriodicCheck() async {
    await Workmanager().registerPeriodicTask(
      kBackgroundTaskUniqueName,
      kBackgroundTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
