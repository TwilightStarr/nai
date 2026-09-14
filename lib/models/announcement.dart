enum AnnouncementCategory { haber, duyuru }

/// Okul sitesinden çekilen tek bir haber/duyuru kaydını temsil eder.
class Announcement {
  /// Sitedeki kalıcı bağlantı (tekilleştirme anahtarı olarak da kullanılır).
  final String url;

  final String title;

  final AnnouncementCategory category;

  /// Liste sayfasında bulunan küçük görsel (varsa).
  final String? thumbnailUrl;

  /// Detay sayfasından çekilen tam metin (henüz çekilmediyse null).
  final String? body;

  /// Detay sayfasındaki büyük görsel (varsa).
  final String? imageUrl;

  /// Sitedeki "Yayın: ..." tarihi metni (varsa, olduğu gibi).
  final String? publishedLabel;

  /// Bu öğenin uygulama tarafından ilk kez görüldüğü an.
  final DateTime firstSeen;

  /// Kullanıcının bu öğeyi açıp içeriğini görüntüleyip görüntülemediği.
  final bool isRead;

  const Announcement({
    required this.url,
    required this.title,
    required this.category,
    required this.firstSeen,
    this.thumbnailUrl,
    this.body,
    this.imageUrl,
    this.publishedLabel,
    this.isRead = false,
  });

  Announcement copyWith({
    String? body,
    String? imageUrl,
    String? publishedLabel,
    bool? isRead,
  }) {
    return Announcement(
      url: url,
      title: title,
      category: category,
      firstSeen: firstSeen,
      thumbnailUrl: thumbnailUrl,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedLabel: publishedLabel ?? this.publishedLabel,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'category': category.name,
        'thumbnailUrl': thumbnailUrl,
        'body': body,
        'imageUrl': imageUrl,
        'publishedLabel': publishedLabel,
        'firstSeen': firstSeen.toIso8601String(),
        'isRead': isRead,
      };

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      url: json['url'] as String,
      title: json['title'] as String,
      category: AnnouncementCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AnnouncementCategory.haber,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
      publishedLabel: json['publishedLabel'] as String?,
      firstSeen: DateTime.tryParse(json['firstSeen'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
