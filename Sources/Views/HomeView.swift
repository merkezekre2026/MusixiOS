import SwiftUI
import MusicKit

struct HomeView: View {
    let playerManager: MusicPlayerManager
    let dataService: MusicDataService
    
    @State private var searchText = ""
    @State private var topCharts: MusicItemCollection<Song> = MusicItemCollection()
    @State private var featuredAlbums: MusicItemCollection<Album> = MusicItemCollection()
    @State private var recentlyPlayed: MusicItemCollection<Song> = MusicItemCollection()
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else {
                        if !featuredAlbums.isEmpty {
                            FeaturedSection(albums: featuredAlbums, onPlay: playAlbum)
                        }
                        
                        if !topCharts.isEmpty {
                            ChartsSection(songs: topCharts, onPlay: playSong)
                        }
                        
                        if !recentlyPlayed.isEmpty {
                            RecentlyPlayedSection(songs: recentlyPlayed, onPlay: playSong)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Keşfet")
            .searchable(text: $searchText, prompt: "Şarkı, albüm veya sanatçı ara")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    Task {
                        await dataService.search(query: newValue)
                    }
                } else {
                    dataService.clearSearch()
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        async let charts = dataService.fetchTopCharts()
        async let albums = dataService.fetchFeaturedAlbums()
        async let recent = dataService.fetchRecentlyPlayed()
        
        topCharts = await charts
        featuredAlbums = await albums
        recentlyPlayed = await recent
        isLoading = false
    }
    
    private func playSong(_ song: Song) {
        Task {
            try? await playerManager.play(song)
        }
    }
    
    private func playAlbum(_ songs: [Song]) {
        guard let first = songs.first else { return }
        Task {
            try? await playerManager.play(songs, startIndex: 0)
        }
    }
}

struct FeaturedSection: View {
    let albums: MusicItemCollection<Album>
    let onPlay: ([Song]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Öne Çıkan Albümler")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(albums) { album in
                        FeaturedAlbumCard(album: album, onPlay: { onPlay([]) })
                    }
                }
            }
        }
    }
}

struct FeaturedAlbumCard: View {
    let album: Album
    let onPlay: () -> Void
    
    private var artworkView: some View {
        Group {
            if let artwork = album.artwork {
                AsyncImage(url: artwork.url(width: 300, height: 300)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artworkView
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(album.title)
                .font(.subheadline)
                .lineLimit(1)
            
            if let artist = album.artistName {
                Text(artist)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 150)
        .onTapGesture {
            onPlay()
        }
    }
}

struct ChartsSection: View {
    let songs: MusicItemCollection<Song>
    let onPlay: (Song) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popüler Şarkılar")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(songs.prefix(10).enumerated()), id: \.element.id) { index, song in
                    SongRowView(song: song, index: index + 1) { onPlay(song) }
                }
            }
        }
    }
}

struct RecentlyPlayedSection: View {
    let songs: MusicItemCollection<Song>
    let onPlay: (Song) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Dinlenenler")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(songs) { song in
                        RecentSongCard(song: song, onTap: { onPlay(song) })
                    }
                }
            }
        }
    }
}

struct RecentSongCard: View {
    let song: Song
    let onTap: () -> Void
    
    private var artworkView: some View {
        Group {
            if let artwork = song.artwork {
                AsyncImage(url: artwork.url(width: 240, height: 240)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artworkView
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(song.title)
                .font(.subheadline)
                .lineLimit(1)
            
            if let artist = song.artistName {
                Text(artist)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 120)
        .onTapGesture(perform: onTap)
    }
}
