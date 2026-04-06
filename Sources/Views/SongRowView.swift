import SwiftUI
import MusicKit

struct SongRowView: View {
    let song: Song
    var index: Int? = nil
    let onTap: () -> Void
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
        .frame(width: 50, height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let index = index {
                    Text("\(index)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
                
                if let artwork = song.artwork {
                    AsyncImage(url: artwork.url(width: 100, height: 100)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            placeholderView
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    placeholderView
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.body)
                        .lineLimit(1)
                    
                    Text(song.artistName ?? "Bilinmiyor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let duration = song.duration {
                    Text(formatDuration(duration))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
