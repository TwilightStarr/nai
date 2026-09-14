import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/announcement.dart';

/// Nevzat Ayaz Anadolu Lisesi (MEB k12) web sitesini tarayıp
/// Haberler ve Duyurular listelerini ayrıştıran servis.
///
/// Not: Site, tüm MEB okullarında ortak kullanılan bir içerik yönetim
/// şablonu üzerine kurulu. Kesin CSS sınıf adları yerine, bu şablonlarda
/// stabil kalan URL örüntülerine (icerikler/*.html, meb_iys_dosyalar/*.pdf
/// vb.) dayalı, dayanıklı bir ayrıştırma stratejisi kullanılır. Şablon
/// büyük ölçüde değişirse [_contentHrefPattern] güncellenmelidir.
class ScraperService {
  ScraperService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String baseUrl = 'https://nevzatayazal.meb.k12.tr';
  static const String homeUrl = baseUrl;
  static const String haberlerListUrl =
      '$baseUrl/icerikler/icerikler/listele_94171_Haberler';
  static const String duyurularListUrl =
      '$baseUrl/icerikler/icerikler/listele_94172_Duyurular';

  static final RegExp _contentHtmlPattern = RegExp(r'/icerikler/.+\.html?$');
  static final RegExp _contentFilePattern =
      RegExp(r'/meb_iys_dosyalar/.+\.(pdf|xlsx?|docx?|zip|rar|pptx?)$');

  static const List<String> _excludedHrefFragments = [
    'listele_',
    'siteharitasi',
    'iletisim.php',
    'index.php',
    'eposta_gonder',
    'harita.php',
  ];

  final _headers = const {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13; NAI-App) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Mobile Safari/537.36',
    'Accept-Language': 'tr-TR,tr;q=0.9',
  };

  Future<Document> _fetchDocument(String url) async {
    final response = await _client
        .get(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $url');
    }
    return html_parser.parse(response.bodyBytes.isNotEmpty
        ? _decode(response.bodyBytes)
        : response.body);
  }

  String _decode(List<int> bytes) {
    try {
      return String.fromCharCodes(bytes);
    } catch (_) {
      return '';
    }
  }

  String _absolute(String href) {
    if (href.startsWith('http://') || href.startsWith('https://')) {
      return href;
    }
    if (href.startsWith('//')) return 'https:$href';
    if (href.startsWith('/')) return '$baseUrl$href';
    return '$baseUrl/$href';
  }

  bool _isContentHref(String href) {
    if (_excludedHrefFragments.any((f) => href.contains(f))) return false;
    return _contentHtmlPattern.hasMatch(href) ||
        _contentFilePattern.hasMatch(href);
  }

  /// Bir liste sayfasındaki (anasayfa ya da "Devamı" sayfası) tüm
  /// haber/duyuru bağlantılarını çıkarır.
  List<Announcement> _extractFromListPage(
    Document doc,
    AnnouncementCategory category,
  ) {
    final seenUrls = <String>{};
    final results = <Announcement>[];

    for (final a in doc.querySelectorAll('a[href]')) {
      final rawHref = a.attributes['href']?.trim();
      if (rawHref == null || rawHref.isEmpty || rawHref.startsWith('#')) {
        continue;
      }
      final href = _absolute(rawHref);
      if (!_isContentHref(href)) continue;

      final title = a.text.trim().isNotEmpty
          ? a.text.trim()
          : (a.querySelector('img')?.attributes['alt']?.trim() ?? '');
      if (title.isEmpty) continue;
      if (seenUrls.contains(href)) continue;
      seenUrls.add(href);

      // Aynı <li> içinde bir küçük resim var mı diye bak.
      String? thumb;
      Element? container = a.parent;
      for (var i = 0; i < 3 && container != null; i++) {
        final img = container.querySelector('img');
        if (img != null) {
          final src = img.attributes['src']?.trim();
          if (src != null && src.isNotEmpty) {
            thumb = _absolute(src);
          }
          break;
        }
        container = container.parent;
      }

      results.add(Announcement(
        url: href,
        title: title,
        category: category,
        firstSeen: DateTime.now(),
        thumbnailUrl: thumb,
      ));
    }
    return results;
  }

  /// Haberler listesini döndürür (en güncel liste sayfası).
  Future<List<Announcement>> fetchHaberler() async {
    final doc = await _fetchDocument(haberlerListUrl);
    final items = _extractFromListPage(doc, AnnouncementCategory.haber);
    if (items.isNotEmpty) return items;
    // Yedek: liste sayfası boşsa anasayfadan dene.
    final home = await _fetchDocument(homeUrl);
    return _extractFromListPage(home, AnnouncementCategory.haber);
  }

  /// Duyurular listesini döndürür.
  Future<List<Announcement>> fetchDuyurular() async {
    final doc = await _fetchDocument(duyurularListUrl);
    final items = _extractFromListPage(doc, AnnouncementCategory.duyuru);
    if (items.isNotEmpty) return items;
    final home = await _fetchDocument(homeUrl);
    return _extractFromListPage(home, AnnouncementCategory.duyuru);
  }

  /// Her iki listeyi birlikte çeker.
  Future<List<Announcement>> fetchAll() async {
    final results = await Future.wait([fetchHaberler(), fetchDuyurular()]);
    return [...results[0], ...results[1]];
  }

  static const List<String> _boilerplateContains = [
    'toggle navigation',
    'millî eğitim bakanlığı',
    'milli eğitim bakanlığı',
    'm.e.b ©',
    'tüm hakları saklıdır',
    'beğen',
    'kişi beğendi',
    'hata bildir',
    'bu içerikte hata var',
    'bu sayfa i̇le i̇lgili',
    'bu sayfa ile ilgili',
    'yayın:',
    'paylaş facebook',
    'paylaş twitter',
    'fatih projesi',
    'kdk çocuk',
    'güvenli i̇nternet',
    'güvenli internet',
    'mesleğim hayatım',
    '444 0 meb',
    'mebbis',
    'e-okul veli',
    'e-devlet kapısı',
    'cumhurbaşkanlığı i̇letişim',
    'i̇statistiki bilgileri',
    'gönder',
    'gizlilik, kullanım',
  ];

  /// Bir içerik (haber/duyuru) sayfasının tam metnini ve görselini çeker.
  Future<Announcement> fetchDetail(Announcement stub) async {
    try {
      final doc = await _fetchDocument(stub.url);

      String? ogImage;
      for (final meta in doc.querySelectorAll('meta')) {
        final prop = meta.attributes['property'] ?? meta.attributes['name'];
        if (prop == 'og:image') {
          ogImage = meta.attributes['content']?.trim();
        }
      }

      String? publishedLabel;
      final lines = doc.body?.text
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList() ??
          [];

      for (final l in lines) {
        if (l.startsWith('Yayın:')) {
          publishedLabel = l;
          break;
        }
      }

      String? body;
      String bestLine = '';
      for (final l in lines) {
        final lower = l.toLowerCase();
        final isBoilerplate =
            _boilerplateContains.any((b) => lower.contains(b));
        if (isBoilerplate) continue;
        if (lower == stub.title.toLowerCase()) continue;
        if (l.length > bestLine.length) {
          bestLine = l;
        }
      }
      if (bestLine.length >= 20) {
        body = bestLine;
      }

      return stub.copyWith(
        body: body,
        imageUrl: ogImage != null ? _absolute(ogImage) : stub.thumbnailUrl,
        publishedLabel: publishedLabel,
      );
    } catch (_) {
      // Detay çekilemezse en azından liste bilgisiyle devam edilir.
      return stub;
    }
  }

  void dispose() => _client.close();
}
