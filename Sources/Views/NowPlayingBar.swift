import SwiftUI
import MusicKit

struct NowPlayingBar: View {
    let playerManager: MusicPlayerManager
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let song = playerManager.currentSong {
                HStack(spacing: 12) {
                    if let artwork = song.artwork {
                        AsyncImage(url: artwork.url(width: 80, height: 80)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            default:
                                placeholderView
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        placeholderView
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Text(song.artistName ?? "Bilinmiyor")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            try? await playerManager.togglePlayPause()
                        }
                    } label: {
                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }
                    
                    Button {
                        Task {
                            try? await playerManager.skipToNext()
                        }
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
        }
        .frame(height: 56)
    }
}
