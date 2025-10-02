import UIKit
import Photos

class PhotoSavingService {
    enum PhotoSavingError: Error, LocalizedError {
        case accessDenied
        case accessRestricted
        case unknownError

        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and allow access for this app."
            case .accessRestricted:
                return "Photo library access is restricted and cannot be granted."
            case .unknownError:
                return "An unknown error occurred while saving the photo."
            }
        }
    }

    func saveImage(_ image: UIImage) async throws {
        var status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if status == .notDetermined {
            status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }
        
        guard status == .authorized else {
            if status == .denied { throw PhotoSavingError.accessDenied }
            if status == .restricted { throw PhotoSavingError.accessRestricted }
            throw PhotoSavingError.unknownError
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
} 