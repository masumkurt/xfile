# ⚡ XFile — Gelişmiş Android Dosya Yöneticisi

ES File Explorer / X-plore benzeri, Flutter ile yazılmış tam özellikli dosya yöneticisi.

## Özellikler

- 📁 Tam dosya sistemi gezintisi (geri/ileri/yukarı)
- 🔍 Anlık dosya arama
- 📊 Grid ve Liste görünümü
- ✅ Çoklu seçim (uzun basış ile)
- 📋 Kopyala / Kes / Yapıştır / Sil / Yeniden Adlandır
- 📂 Yeni klasör oluşturma
- 🏷️ Yer imi sistemi
- 📎 Context menu (uzun basış bottom sheet)
- 🔃 Ada / Boyuta / Tarihe / Türe göre sıralama
- 📍 Breadcrumb navigasyonu
- 🎨 Dark tema, XFile özel renk paleti

## Kurulum

### Gereksinimler
- Flutter SDK 3.x
- Android Studio veya VS Code
- Android SDK (min API 21 / Android 5.0)

### Adımlar

```bash
# 1. Projeyi klonla veya çıkart
cd xfile_flutter

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Android cihaz veya emülatöre bağlan
flutter devices

# 4. Çalıştır
flutter run

# 5. Release APK derle
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk

# 6. Bölünmüş APK (daha küçük boyut)
flutter build apk --split-per-abi
```

### İzinler
Android 11+ için ayarlar → Uygulama → XFile → İzinler → Tüm dosyalara erişim → İzin ver

## Proje Yapısı

```
lib/
├── main.dart                    # Giriş noktası, tema
├── models/
│   └── file_manager_state.dart  # Tüm iş mantığı (Provider)
├── screens/
│   └── home_screen.dart         # Ana ekran
└── widgets/
    ├── breadcrumb_bar.dart      # Yol navigasyonu
    ├── bottom_action_bar.dart   # Çoklu seçim araç çubuğu
    ├── file_context_menu.dart   # Sağ tık / uzun basış menüsü
    ├── file_grid_view.dart      # Grid görünümü
    ├── file_list_view.dart      # Liste görünümü
    ├── sidebar_drawer.dart      # Sol menü
    └── sort_dialog.dart         # Sıralama diyaloğu
```

## Genişletme Fikirleri

- **Arşiv desteği**: `archive` paketi zaten eklendi, ZIP oluşturma/açma eklenebilir
- **FTP/SMB**: Ağ depolamaya bağlantı
- **Bulut**: Google Drive / Dropbox entegrasyonu
- **Medya önizleme**: Resim/video thumbnail'leri
- **Root erişimi**: Root'lu cihazlarda `/system` gezintisi
- **Tema**: Açık tema seçeneği

## Paketler

| Paket | Kullanım |
|-------|----------|
| provider | State management |
| path_provider | Depolama yolları |
| permission_handler | İzin yönetimi |
| open_file | Dosya açma |
| google_fonts | Roboto font |
| intl | Tarih formatlama |
| archive | ZIP desteği (hazır) |
