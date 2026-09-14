import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/update_checker.dart';
import '../theme/app_theme.dart';
import '../widgets/sparkle_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  bool _notificationsEnabled = true;
  bool _checking = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _storage.getNotificationsEnabled();
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = 'v${info.version} (${info.buildNumber})';
    } catch (_) {
      version = '';
    }
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _version = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionCard(
            children: [
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (v) async {
                  await _storage.setNotificationsEnabled(v);
                  if (v) await NotificationService.instance.requestPermission();
                  setState(() => _notificationsEnabled = v);
                },
                title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Sitede yeni haber/duyuru olduğunda bildirim gönder',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue),
                      )
                    : const Icon(Icons.refresh_rounded, color: AppColors.blue),
                title: const Text('Şimdi kontrol et', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Uygulama açıkken siteyi tam olarak 10 dakikada bir otomatik kontrol eder',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
                ),
                onTap: _checking
                    ? null
                    : () async {
                        setState(() => _checking = true);
                        final checker = UpdateChecker(storage: _storage);
                        final count = await checker.checkNow();
                        checker.dispose();
                        if (!mounted) return;
                        setState(() => _checking = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceElevated,
                            content: Text(
                              count > 0
                                  ? '$count yeni içerik bulundu'
                                  : 'Yeni içerik yok, her şey güncel',
                            ),
                          ),
                        );
                      },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.bolt_rounded, color: AppColors.textTertiary),
                title: Text('Arka planda kontrol aralığı', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Android sistem kısıtı nedeniyle uygulama kapalıyken kontroller 15 dakikada bir yapılır. Uygulama açıkken bu süre tam olarak 10 dakikadır.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textTertiary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.language_rounded, color: AppColors.textTertiary),
                title: const Text('Okul web sitesi', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('nevzatayazal.meb.k12.tr', style: TextStyle(fontSize: 12.5, color: AppColors.textTertiary)),
                trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textTertiary),
                onTap: () => launchUrl(
                  Uri.parse('https://nevzatayazal.meb.k12.tr/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const SparkleLogo(size: 40, glow: false),
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (b) => AppColors.gradient.createShader(b),
                  child: const Text(
                    'NAI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (_version.isNotEmpty)
                  Text(_version, style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary)),
                const SizedBox(height: 4),
                const Text(
                  'Geliştirici: Tuğra Çimen',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
