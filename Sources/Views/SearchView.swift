import SwiftUI
import MusicKit

struct SearchView: View {
    let dataService: MusicDataService
    let playerManager: MusicPlayerManager
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if let results = dataService.searchResults {
                    SearchResultsView(
                        results: results,
                        playerManager: playerManager
                    )
                } else {
                    ContentUnavailableView(
                        "Apple Music Kataloğunda Ara",
                        systemImage: "magnifyingglass",
                        description: Text("Şarkı, albüm, sanatçı veya müzik videosu arayın")
                    )
                }
            }
            .navigationTitle("Ara")
            .searchable(text: $searchText, prompt: "Şarkı, albüm veya sanatçı ara")
            .onChange(of: searchText) { _, newValue in
                Task {
                    if newValue.count >= 2 {
                        await dataService.search(query: newValue)
                    } else if newValue.isEmpty {
                        dataService.clearSearch()
                    }
                }
            }
        }
    }
}

struct SearchResultsView: View {
    let results: MusicSearchResult
    let playerManager: MusicPlayerManager
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if !results.songs.isEmpty {
                    SearchSection(title: "Şarkılar") {
                        ForEach(results.songs) { song in
                            SongRowView(song: song) {
                                Task {
                                    try? await playerManager.play(song)
                                }
                            }
                        }
                    }
                }
                
                if !results.albums.isEmpty {
                    SearchSection(title: "Albümler") {
                        ForEach(results.albums) { album in
                            AlbumRowView(album: album)
                        }
                    }
                }
                
                if !results.artists.isEmpty {
                    SearchSection(title: "Sanatçılar") {
                        ForEach(results.artists) { artist in
                            ArtistRowView(artist: artist)
                        }
                    }
                }
                
                if !results.musicVideos.isEmpty {
                    SearchSection(title: "Müzik Videoları") {
                        ForEach(results.musicVideos) { video in
                            MusicVideoRowView(video: video, playerManager: playerManager)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct SearchSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            content
        }
    }
}

struct AlbumRowView: View {
    let album: Album
    
    private var artworkView: some View {
        Group {
            if let artwork = album.artwork {
                AsyncImage(url: artwork.url(width: 100, height: 100)) { phase in
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
        HStack(spacing: 12) {
            artworkView
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.body)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

struct ArtistRowView: View {
    let artist: Artist
    
    private var artworkView: some View {
        Group {
            if let artwork = artist.artwork {
                AsyncImage(url: artwork.url(width: 100, height: 100)) { phase in
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
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundStyle(.secondary)
            )
    }
    
    var body: some View {
        HStack(spacing: 12) {
            artworkView
                .clipShape(Circle())
            
            Text(artist.name)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

struct MusicVideoRowView: View {
    let video: MusicVideo
    let playerManager: MusicPlayerManager
    
    private var artworkView: some View {
        Group {
            if let artwork = video.artwork {
                AsyncImage(url: artwork.url(width: 160, height: 100)) { phase in
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
            Image(systemName: "play.rectangle.fill")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            artworkView
                .frame(width: 80, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(video.title)
                    .font(.body)
                    .lineLimit(1)
                
                Text(video.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(formatDuration(180))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
