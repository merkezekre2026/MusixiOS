import SwiftUI
import MusicKit

struct LibraryView: View {
    let dataService: MusicDataService
    let playerManager: MusicPlayerManager
    
    @State private var recentlyPlayed: MusicItemCollection<Song> = MusicItemCollection()
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        if !recentlyPlayed.isEmpty {
                            RecentlyPlayedSectionLibrary(songs: recentlyPlayed, playerManager: playerManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Kitaplık")
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        await dataService.fetchRecentlyPlayed()
        recentlyPlayed = dataService.recentlyPlayed
        isLoading = false
    }
}

struct RecentlyPlayedSectionLibrary: View {
    let songs: MusicItemCollection<Song>
    let playerManager: MusicPlayerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Dinlenenler")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 0) {
                ForEach(songs) { song in
                    SongRowView(song: song, onTap: {
                        Task {
                            try? await playerManager.play(song)
                        }
                    })
                }
            }
        }
    }
}
