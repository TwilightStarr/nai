import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/announcement.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final isDuyuru = item.category == AnnouncementCategory.duyuru;
    final accent = isDuyuru ? AppColors.purple : AppColors.cyan;
    final imageUrl = item.imageUrl ?? item.thumbnailUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            expandedHeight: imageUrl != null ? 220 : 90,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(gradient: AppColors.gradientSoft),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.background.withValues(alpha: 0.1),
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isDuyuru ? 'DUYURU' : 'HABER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: accent,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 60.ms, duration: 350.ms).slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 10),
                  if (item.publishedLabel != null)
                    Text(
                      item.publishedLabel!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  if (item.body != null)
                    Text(
                      item.body!,
                      style: const TextStyle(
                        fontSize: 15.5,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 400.ms)
                  else
                    const _NoBodyNotice(),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onPressed: () => launchUrl(
                        Uri.parse(item.url),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Okul sitesinde aç'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBodyNotice extends StatelessWidget {
  const _NoBodyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textTertiary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bu içeriğin tam metni alınamadı. Detayları görmek için sitede açabilirsin.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
