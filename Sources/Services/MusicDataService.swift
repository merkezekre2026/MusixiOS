import Foundation
import MusicKit

struct MusicSearchResult: Identifiable {
    let id: String
    let songs: MusicItemCollection<Song>
    let albums: MusicItemCollection<Album>
    let artists: MusicItemCollection<Artist>
    let musicVideos: MusicItemCollection<MusicVideo>
}

@Observable
final class MusicDataService {
    var searchResults: MusicSearchResult?
    var recentlyPlayed: MusicItemCollection<Song> = MusicItemCollection()
    var isLoading: Bool = false
    var errorMessage: String?
    
    func search(query: String) async {
        guard !query.isEmpty else {
            searchResults = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var request = MusicCatalogSearchRequest(term: query, types: [Song.self, Album.self, Artist.self, MusicVideo.self])
            request.limit = 25
            
            let response = try await request.response()
            
            searchResults = MusicSearchResult(
                id: UUID().uuidString,
                songs: response.songs,
                albums: response.albums,
                artists: response.artists,
                musicVideos: response.musicVideos
            )
        } catch {
            errorMessage = "Arama başarısız: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchRecentlyPlayed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var request = MusicRecentlyPlayedRequest<Song>()
            request.limit = 20
            
            let response = try await request.response()
            recentlyPlayed = response.items
        } catch {
            errorMessage = "Son dinlenenler getirilemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchTopCharts() async -> MusicItemCollection<Song> {
        do {
            var request = MusicCatalogChartsRequest(kinds: [.mostPlayed], types: [Song.self])
            request.limit = 20
            
            let response = try await request.response()
            return response.songCharts.first?.items ?? MusicItemCollection()
        } catch {
            errorMessage = "Popüler şarkılar getirilemedi: \(error.localizedDescription)"
            return MusicItemCollection()
        }
    }
    
    func fetchFeaturedAlbums() async -> MusicItemCollection<Album> {
        do {
            var request = MusicCatalogChartsRequest(kinds: [.mostPlayed], types: [Album.self])
            request.limit = 10
            
            let response = try await request.response()
            return response.albumCharts.first?.items ?? MusicItemCollection()
        } catch {
            return MusicItemCollection()
        }
    }
    
    func fetchAlbumDetails(id: MusicItemID) async -> Album? {
        do {
            let request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: id)
            return try await request.response().items.first
        } catch {
            return nil
        }
    }
    
    func clearSearch() {
        searchResults = nil
    }
}
