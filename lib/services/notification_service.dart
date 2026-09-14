import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/announcement.dart';

/// Yerel bildirimlerin oluşturulmasından ve izin isteğinden sorumludur.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'nai_updates_channel';
  static const _channelName = 'NAI Güncellemeleri';
  static const _channelDesc =
      'Okul sitesinde yeni haber veya duyuru olduğunda bildirim gönderir.';

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> notifyNewAnnouncement(Announcement item) async {
    await init();
    final categoryLabel =
        item.category == AnnouncementCategory.haber ? 'Yeni Haber' : 'Yeni Duyuru';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      category: AndroidNotificationCategory.status,
    );
    const details = NotificationDetails(android: androidDetails);

    final id = Random().nextInt(1 << 31);
    await _plugin.show(
      id,
      '$categoryLabel · Nevzat Ayaz Anadolu Lisesi',
      item.title,
      details,
      payload: item.url,
    );
  }

  Future<void> notifySummary(int count) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      Random().nextInt(1 << 31),
      'NAI · $count yeni içerik',
      'Okul sitesinde $count yeni haber/duyuru yayınlandı. Görmek için dokunun.',
      details,
    );
  }
}
