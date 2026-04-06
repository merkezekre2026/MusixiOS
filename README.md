# MusixiOS

Apple MusicKit framework'ü ile geliştirilmiş profesyonel bir iOS müzik uygulaması.

## Özellikler

- **Apple Music Entegrasyonu**: MusicKit ile katalog araması ve oynatma
- **Son Dinlenenler**: MusicRecentlyPlayedRequest ile kullanıcının dinleme geçmişi
- **Popüler Şarkılar**: Apple Musiccharts API ile trend şarkılar
- **Modern Swift**: @Observable ile MVVM mimarisi
- **SwiftUI**: Apple Music tasarım diline uygun arayüz

## Gereksinimler

- iOS 17.0+
- Xcode 15.0+
- Apple Developer Account (MusicKit yetkilenirmesi için)

## Kurulum

```bash
# Projeyi aç
open MusixiOS.xcodeproj

# Veya command line ile build
xcodegen generate
xcodebuild -project MusixiOS.xcodeproj -scheme MusixiOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO build
```

## Proje Yapısı

```
Sources/
├── App/
│   └── MusixiOSApp.swift           # Uygulama entry point
├── Services/
│   ├── MusicAuthorizationService.swift  # Yetkilendirme
│   ├── MusicPlayerManager.swift          # SystemMusicPlayer
│   └── MusicDataService.swift            # Veri çekme (search, charts, recently played)
└── Views/
    ├── ContentView.swift            # Ana view
    ├── MainTabView.swift           # Tab navigation
    ├── HomeView.swift              # Keşfet & Popüler şarkılar
    ├── SearchView.swift            # Katalog arama
    ├── LibraryView.swift           # Son dinlenenler
    ├── SongRowView.swift           # Şarkı satırı
    └── NowPlayingBar.swift         # Oynatma kontrolü
```

## Kullanılan MusicKit API'leri

- `MusicAuthorization.request()` - Kullanıcı yetkilendirmesi
- `MusicCatalogSearchRequest` - Katalog araması
- `MusicRecentlyPlayedRequest` - Dinleme geçmişi
- `MusicCatalogChartsRequest` - Popüler şarkılar/albümler
- `SystemMusicPlayer.shared` - Müzik oynatma

## Lisans

MIT License
