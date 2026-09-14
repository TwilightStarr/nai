import '../models/announcement.dart';
import 'notification_service.dart';
import 'scraper_service.dart';
import 'storage_service.dart';

/// Siteyi kontrol edip yeni içerik varsa kaydeden ve bildirim gönderen
/// tek merkezi rutin. Hem uygulama açıkken (zamanlayıcı ile) hem de
/// arka planda (WorkManager ile) bu sınıf çağrılır.
class UpdateChecker {
  UpdateChecker({ScraperService? scraper, StorageService? storage})
      : _scraper = scraper ?? ScraperService(),
        _storage = storage ?? StorageService();

  final ScraperService _scraper;
  final StorageService _storage;

  /// Siteyi kontrol eder. Yeni bulunan öğe sayısını döndürür.
  Future<int> checkNow({bool sendNotifications = true}) async {
    final existing = await _storage.loadAll();
    final existingUrls = existing.map((e) => e.url).toSet();

    List<Announcement> fetched;
    try {
      fetched = await _scraper.fetchAll();
    } catch (_) {
      // Ağ hatası: sessizce vazgeç, bir sonraki denemede tekrar dener.
      return 0;
    }

    final newOnes = <Announcement>[];
    for (final item in fetched) {
      if (!existingUrls.contains(item.url)) {
        newOnes.add(item);
      }
    }

    await _storage.setLastCheck(DateTime.now());

    if (newOnes.isEmpty) {
      return 0;
    }

    // Yeni öğelerin tam içeriğini (metin + görsel) çek.
    final detailed = <Announcement>[];
    for (final item in newOnes) {
      detailed.add(await _scraper.fetchDetail(item));
    }

    final notificationsOn = await _storage.getNotificationsEnabled();
    if (sendNotifications && notificationsOn) {
      if (detailed.length == 1) {
        await NotificationService.instance.notifyNewAnnouncement(detailed.first);
      } else {
        await NotificationService.instance.notifySummary(detailed.length);
      }
    }

    final merged = [...detailed, ...existing];
    // Aynı URL'den birden fazla varsa tekilleştir (en yeni kazanır).
    final seen = <String>{};
    final deduped = <Announcement>[];
    for (final item in merged) {
      if (seen.add(item.url)) deduped.add(item);
    }

    await _storage.saveAll(deduped);
    return detailed.length;
  }

  void dispose() => _scraper.dispose();
}
