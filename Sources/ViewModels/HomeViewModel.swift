import Foundation
import MusicKit

@Observable
final class HomeViewModel {
    let playerManager: MusicPlayerManager
    let dataService: MusicDataService
    
    var searchQuery: String = ""
    var topCharts: MusicItemCollection<Song> = MusicItemCollection()
    var featuredAlbums: MusicItemCollection<Album> = MusicItemCollection()
    var selectedTab: HomeTab = .featured
    
    enum HomeTab {
        case featured
        case charts
        case recentlyPlayed
    }
    
    init(playerManager: MusicPlayerManager, dataService: MusicDataService) {
        self.playerManager = playerManager
        self.dataService = dataService
    }
    
    func loadInitialData() async {
        async let chartsTask = dataService.fetchTopCharts()
        async let albumsTask = dataService.fetchFeaturedAlbums()
        async let recentTask = dataService.fetchRecentlyPlayed()
        
        topCharts = await chartsTask
        featuredAlbums = await albumsTask
        _ = await recentTask
    }
    
    func performSearch() async {
        await dataService.search(query: searchQuery)
    }
    
    func playSong(_ song: Song) async {
        do {
            try await playerManager.play(song)
        } catch {
            print("Playback error: \(error)")
        }
    }
    
    func playAlbum(_ songs: [Song]) async {
        guard let firstSong = songs.first else { return }
        do {
            try await playerManager.play(songs, startIndex: 0)
        } catch {
            print("Playback error: \(error)")
        }
    }
}
