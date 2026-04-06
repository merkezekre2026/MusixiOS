import SwiftUI
import MusicKit

struct AlbumArtworkView: View {
    let artwork: Artwork?
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(artwork: Artwork?, size: CGFloat, cornerRadius: CGFloat = 0) {
        self.artwork = artwork
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let artwork = artwork {
                AsyncImage(url: artwork.url(width: Int(size * 2), height: Int(size * 2))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    case .empty:
                        placeholderView
                            .overlay(ProgressView())
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3))
                .foregroundStyle(.secondary)
        }
    }
}
