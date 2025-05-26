# FTH Admin Panel

Flutter ile geliştirilmiş modern bir admin paneli uygulaması.

## Özellikler

- Modern ve şık kullanıcı arayüzü
- Koyu/Açık tema desteği
- Hızlı ve akıcı kullanıcı deneyimi
- Responsive tasarım

## Kurulum

1. Projeyi klonlayın:
   ```bash
   git clone [repo-url]
   cd fth-admin
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Kullanılan Paketler

- `another_flutter_splash_screen: ^1.2.1` - Profesyonel splash ekranı için
- `adaptive_theme: ^3.7.0` - Tema yönetimi için
- `easy_sidemenu: ^0.6.1` - Yan menü için
- `go_router: ^13.0.0` - Navigasyon için
- `google_fonts: ^6.1.0` - Google Fontlar için
- `flutter_svg: ^2.0.10+1` - SVG desteği için

## Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_service.dart
│   └── utils/
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   ├── about/
│   │   └── presentation/
│   │       └── pages/
│   └── splash/
│       └── presentation/
│           └── pages/
├── routes/
│   └── app_router.dart
└── shared/
    └── widgets/
```

## Ekran Görüntüleri

<!-- Buraya ekran görüntüleri eklenecek -->

## Lisans

MIT