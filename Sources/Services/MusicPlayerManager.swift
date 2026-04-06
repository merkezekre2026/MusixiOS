import Foundation
import MusicKit
import Combine

@Observable
final class MusicPlayerManager {
    private let player = SystemMusicPlayer.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isPlaying: Bool = false
    var currentPlaybackTime: TimeInterval = 0
    var currentEntryID: MusicItemID?
    var currentSong: Song?
    var currentAlbumArt: Artwork?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        player.state.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateState()
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentPlaybackTime = self?.player.playbackTime ?? 0
            }
            .store(in: &cancellables)
    }
    
    private func updateState() {
        isPlaying = player.state.playbackStatus == .playing
    }
    
    func play(_ song: Song) async throws {
        player.queue = [song]
        try await player.play()
        currentSong = song
        currentAlbumArt = song.artwork
        currentEntryID = song.id
    }
    
    func play(_ songs: [Song], startIndex: Int = 0) async throws {
        guard !songs.isEmpty else { return }
        player.queue = MusicPlayer.Queue(for: songs, startingAt: songs[startIndex])
        try await player.play()
        currentSong = songs[startIndex]
        currentAlbumArt = songs[startIndex].artwork
        currentEntryID = songs[startIndex].id
    }
    
    func play() async throws {
        try await player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayPause() async throws {
        if isPlaying {
            pause()
        } else {
            try await play()
        }
    }
    
    func skipToNext() async throws {
        try await player.skipToNextEntry()
    }
    
    func skipToPrevious() async throws {
        try await player.skipToPreviousEntry()
    }
    
    func seek(to time: TimeInterval) async throws {
        player.playbackTime = time
    }
    
    var playbackProgress: Double {
        guard let duration = currentSong?.duration,
              duration > 0 else { return 0 }
        return currentPlaybackTime / duration
    }
    
    var formattedCurrentTime: String {
        formatTime(currentPlaybackTime)
    }
    
    var formattedTotalTime: String {
        guard let duration = currentSong?.duration else { return "--:--" }
        return formatTime(duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
