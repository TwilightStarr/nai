# NAI

**Nevzat Ayaz Anadolu Lisesi** web sitesini (https://nevzatayazal.meb.k12.tr) takip eden,
yeni haber/duyuru yayınlandığında bildirim gönderen ve içeriği uygulama içinde
gösteren Flutter uygulaması.

Geliştirici: **Tuğra Çimen**

---

## Nasıl çalışır?

- Uygulama, okul sitesindeki **Haberler** ve **Duyurular** listelerini düzenli
  aralıklarla kontrol eder.
- Daha önce görülmemiş bir başlık bulunduğunda:
  1. İlgili sayfanın tam metnini ve görselini çeker.
  2. Yerel bir **bildirim** gönderir.
  3. İçeriği uygulama içinde (Haberler/Duyurular/Tümü sekmelerinde) gösterir.
- **Uygulama açıkken**: kontrol tam olarak **10 dakikada** bir yapılır
  (`ForegroundPoller`).
- **Uygulama kapalı/arka plandayken**: Android işletim sistemi, pil ömrünü
  korumak için periyodik arka plan görevlerine **15 dakikadan kısa** bir
  aralık vermez. Bu yüzden arka plan kontrolü `WorkManager` ile 15 dakikada
  bir yapılır. Bu, uygulamanın değil Android'in bir kısıtıdır.
- Ayarlar ekranından bildirimler kapatılabilir ve "Şimdi kontrol et" ile
  anlık kontrol yapılabilir.

## Teknik notlar / sınırlamalar

- Site, MEB'in tüm k12 okullarında kullandığı ortak bir CMS şablonu
  üzerine kurulu. Kesin CSS sınıf adları yerine URL örüntülerine
  (`/icerikler/*.html`, `/meb_iys_dosyalar/*.pdf` vb.) dayalı dayanıklı bir
  ayrıştırma stratejisi kullanılır (`lib/services/scraper_service.dart`).
  Site şablonu köklü biçimde değişirse bu dosyadaki regex'lerin
  güncellenmesi gerekebilir.
- Detay sayfasındaki gövde metni, sayfadaki menü/altbilgi gibi sabit
  metinleri (boilerplate) eleyip en uzun anlamlı paragrafı seçen bir
  sezgisel yöntemle çıkarılır. Bazı sayfalarda (ör. sadece PDF/Excel
  bağlantısı olan duyurular) gövde metni bulunamayabilir; bu durumda
  uygulama "Okul sitesinde aç" butonunu gösterir.
- Yayın imzalama (release signing): Hızlı APK üretimi için şimdilik
  `debug` imzalama anahtarı kullanılıyor (`android/app/build.gradle`).
  Play Store'a yüklemek istersen kendi keystore'unu oluşturup
  `signingConfigs` bölümünü güncellemen gerekir.



## Yerelde çalıştırma (opsiyonel)

Flutter SDK kuruluysa:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

Release APK üretmek için:

```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

## Proje yapısı

```
lib/
  main.dart                     # Giriş noktası, WorkManager kaydı
  theme/app_theme.dart          # Koyu tema + renk paleti
  models/announcement.dart      # Haber/duyuru veri modeli
  services/
    scraper_service.dart        # Siteyi tarayıp veri çeken servis
    storage_service.dart        # SharedPreferences ile kalıcı depolama
    notification_service.dart   # Yerel bildirimler
    update_checker.dart         # Kontrol + karşılaştırma + bildirim mantığı
    background_service.dart     # WorkManager (arka plan, 15 dk)
    foreground_poller.dart      # Uygulama açıkken 10 dk zamanlayıcı
  widgets/
    sparkle_logo.dart           # Vektörel kıvılcım logosu
    announcement_card.dart      # Liste kartı
    loading_list.dart           # Shimmer yükleme efekti
  screens/
    splash_screen.dart
    home_screen.dart            # Tümü / Haberler / Duyurular sekmeleri
    detail_screen.dart
    settings_screen.dart
tools/make_icon.py              # Uygulama ikonunu üreten Python betiği
assets/icon/                    # Üretilmiş ikon dosyaları
android/                        # Native Android proje dosyaları
.github/workflows/build-apk.yml # CI: APK derleme
```
