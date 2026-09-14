import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/announcement.dart';
import '../theme/app_theme.dart';

String relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24) return '${diff.inHours} sa önce';
  if (diff.inDays < 7) return '${diff.inDays} gün önce';
  return '${time.day}.${time.month}.${time.year}';
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.item,
    required this.onTap,
    this.index = 0,
  });

  final Announcement item;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDuyuru = item.category == AnnouncementCategory.duyuru;

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.blue.withValues(alpha: 0.35),
          width: item.isRead ? 1 : 1.4,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumb(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryBadge(isDuyuru: isDuyuru),
                          const Spacer(),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.gradient,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if (item.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.body!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        relativeTime(item.firstSeen),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return card
        .animate(delay: Duration(milliseconds: 30 * (index % 12)))
        .fadeIn(duration: 320.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 320.ms, curve: Curves.easeOut);
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final url = item.thumbnailUrl ?? item.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(gradient: AppColors.gradientSoft),
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _fallbackIcon();
                },
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(Icons.auto_awesome_rounded, color: Colors.white70, size: 26),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.isDuyuru});
  final bool isDuyuru;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: (isDuyuru ? AppColors.purple : AppColors.cyan).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isDuyuru ? 'DUYURU' : 'HABER',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isDuyuru ? AppColors.purple : AppColors.cyan,
        ),
      ),
    );
  }
}
