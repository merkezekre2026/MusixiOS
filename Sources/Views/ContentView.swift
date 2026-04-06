import SwiftUI
import MusicKit

struct ContentView: View {
    @Environment(MusicAuthorizationService.self) private var authService
    @State private var playerManager = MusicPlayerManager()
    @State private var dataService = MusicDataService()
    @State private var showPermissionAlert = false
    
    var body: some View {
        Group {
            if authService.isAuthorized {
                MainTabView(
                    playerManager: playerManager,
                    dataService: dataService
                )
            } else {
                PermissionRequestView {
                    Task {
                        let granted = await authService.requestAccess()
                        if !granted {
                            showPermissionAlert = true
                        }
                    }
                }
            }
        }
        .onAppear {
            if authService.status == .notDetermined {
                Task {
                    _ = await authService.requestAccess()
                }
            }
        }
        .alert("Müzik Erişimi Gerekli", isPresented: $showPermissionAlert) {
            Button("Ayarlar") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("MusixiOS'in müzik dinlemesi için Apple Music erişim izni vermeniz gerekiyor.")
        }
    }
}

struct PermissionRequestView: View {
    let onRequest: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundStyle(.primary)
            
            Text("Müziğe Hoş Geldiniz")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Apple Music kataloğunu keşfetmek ve kendi müzik listenizi dinlemek için izin vermeniz gerekiyor.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onRequest) {
                Text("İzin Ver")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
}
