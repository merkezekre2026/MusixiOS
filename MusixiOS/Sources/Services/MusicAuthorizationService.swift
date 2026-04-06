import Foundation
import MusicKit

enum MusicAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

@Observable
final class MusicAuthorizationService {
    var status: MusicAuthorizationStatus = .notDetermined
    var isAuthorized: Bool = false
    
    init() {
        checkCurrentStatus()
    }
    
    private func checkCurrentStatus() {
        let currentStatus = MusicAuthorization.currentStatus
        mapStatus(currentStatus)
    }
    
    private func mapStatus(_ status: MusicKit.MusicAuthorization.Status) {
        switch status {
        case .notDetermined:
            self.status = .notDetermined
            self.isAuthorized = false
        case .authorized:
            self.status = .authorized
            self.isAuthorized = true
        case .denied:
            self.status = .denied
            self.isAuthorized = false
        case .restricted:
            self.status = .restricted
            self.isAuthorized = false
        @unknown default:
            self.status = .notDetermined
            self.isAuthorized = false
        }
    }
    
    func requestAccess() async -> Bool {
        let result = await MusicAuthorization.request()
        mapStatus(result)
        return isAuthorized
    }
}
