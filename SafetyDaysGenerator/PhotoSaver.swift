import Foundation
import Photos
import UIKit

enum PhotoSaveError: LocalizedError {
    case permissionDenied
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "请在弹窗中允许访问相册"
        case .saveFailed(let m):
            return "保存失败:\(m)"
        }
    }
}

@MainActor
enum PhotoSaver {
    static func save(image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoSaveError.permissionDenied
        }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }
        } catch {
            throw PhotoSaveError.saveFailed(error.localizedDescription)
        }
    }
}
