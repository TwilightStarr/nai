import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/announcement.dart';
import '../services/foreground_poller.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/announcement_card.dart';
import '../widgets/loading_list.dart';
import '../widgets/sparkle_logo.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  late final ForegroundPoller _poller;
  late final TabController _tabController;

  List<Announcement> _items = [];
  bool _loading = true;
  bool _refreshing = false;
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _poller = ForegroundPoller(storage: _storage);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
    await _loadFromDisk();
    await _poller.start();
    _poller.onUpdate.listen((count) {
      _loadFromDisk();
    });
    // İlk açılışta da bir kere hemen kontrol et.
    // ignore: discarded_futures
    _poller.checkImmediately();
  }

  Future<void> _loadFromDisk() async {
    final items = await _storage.loadAll();
    final lastCheck = await _storage.getLastCheck();
    items.sort((a, b) => b.firstSeen.compareTo(a.firstSeen));
    if (!mounted) return;
    setState(() {
      _items = items;
      _lastCheck = lastCheck;
      _loading = false;
    });
  }

  Future<void> _manualRefresh() async {
    setState(() => _refreshing = true);
    await _poller.checkImmediately();
    await _loadFromDisk();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  void dispose() {
    _poller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Announcement> get _haberler =>
      _items.where((e) => e.category == AnnouncementCategory.haber).toList();
  List<Announcement> get _duyurular =>
      _items.where((e) => e.category == AnnouncementCategory.duyuru).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const SparkleLogo(size: 28, glow: false),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (b) => AppColors.gradient.createShader(b),
              child: const Text(
                'NAI',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      _refreshing ? Icons.sync_rounded : Icons.check_circle_outline_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _refreshing
                            ? 'Kontrol ediliyor...'
                            : _lastCheck != null
                                ? 'Son kontrol: ${relativeTime(_lastCheck!)}'
                                : 'Henüz kontrol edilmedi',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: AppColors.blue),
                  insets: EdgeInsets.symmetric(horizontal: 18),
                ),
                tabs: [
                  Tab(text: 'Tümü (${_items.length})'),
                  Tab(text: 'Haberler (${_haberler.length})'),
                  Tab(text: 'Duyurular (${_duyurular.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const LoadingList()
          : TabBarView(
              controller: _tabController,
              children: [
                _AnnouncementList(items: _items, onRefresh: _manualRefresh, storage: _storage, onChanged: _loadFromDisk),
                _AnnouncementList(items: _haberler, onRefresh: _manualRefresh, storage: _storage, onChanged: _loadFromDisk),
                _AnnouncementList(items: _duyurular, onRefresh: _manualRefresh, storage: _storage, onChanged: _loadFromDisk),
              ],
            ),
    );
  }
}

class _AnnouncementList extends StatelessWidget {
  const _AnnouncementList({
    required this.items,
    required this.onRefresh,
    required this.storage,
    required this.onChanged,
  });

  final List<Announcement> items;
  final Future<void> Function() onRefresh;
  final StorageService storage;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.blue,
        backgroundColor: AppColors.surfaceSolid,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            Column(
              children: [
                const SparkleLogo(size: 48, glow: false)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 900.ms)
                    .then()
                    .fadeOut(duration: 900.ms),
                const SizedBox(height: 16),
                const Text(
                  'Henüz içerik yok',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aşağı çekerek yenileyebilirsin',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12.5),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.blue,
      backgroundColor: AppColors.surfaceSolid,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 24),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return AnnouncementCard(
            item: item,
            index: i,
            onTap: () async {
              await storage.markAsRead(item.url);
              await onChanged();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                );
              }
            },
          );
        },
      ),
    );
  }
}
