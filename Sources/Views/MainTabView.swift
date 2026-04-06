import SwiftUI
import MusicKit

struct MainTabView: View {
    let playerManager: MusicPlayerManager
    let dataService: MusicDataService
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView(
                    playerManager: playerManager,
                    dataService: dataService
                )
                .tabItem {
                    Label("Keşfet", systemImage: "house.fill")
                }
                
                SearchView(
                    dataService: dataService,
                    playerManager: playerManager
                )
                .tabItem {
                    Label("Ara", systemImage: "magnifyingglass")
                }
                
                LibraryView(
                    dataService: dataService,
                    playerManager: playerManager
                )
                .tabItem {
                    Label("Kitaplık", systemImage: "music.note.list")
                }
            }
            
            if playerManager.currentSong != nil {
                NowPlayingBar(playerManager: playerManager)
                    .padding(.bottom, 49)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
