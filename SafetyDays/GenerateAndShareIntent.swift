import AppIntents
import Photos
import SwiftUI
import UIKit

// MARK: - 通知：Siri 触发生成完成（供主界面刷新预览）

extension Notification.Name {
    static let safetyDaysImageGenerated = Notification.Name("safetyDaysImageGenerated")
}

// MARK: - 共享分享面板（ContentView 与 Siri Intent 共用）

enum ShareSheetPresenter {

    static func present(_ image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks
        ]

        // iPad 需要 popover 锚点；iPhone 全屏 present
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.rootViewController?.view
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.keyWindow?.rootViewController {
            var presenter = rootVC
            while let presented = presenter.presentedViewController {
                presenter = presented
            }
            presenter.present(activityVC, animated: true)
        }
    }
}

// MARK: - 错误

enum IntentError: Error {
    case invalidDate
    case templateMissing
}

// MARK: - Siri 快捷指令："发安全天数"

@available(iOS 16.0, *)
struct GenerateAndShareIntent: AppIntent {

    static var title: LocalizedStringResource = "发安全天数"
    static var description = IntentDescription(
        "生成安全天数图片，保存到相册并弹出分享面板",
        categoryName: "安全天数"
    )

    func perform() async throws -> some IntentResult {
        // 读取与主界面一致的持久化设置（AppStorage 同 key）
        let defaults = UserDefaults.standard
        let startDateString = defaults.string(forKey: "defaultStartDate") ?? "2023-05-18"

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"

        guard let start = formatter.date(from: startDateString) else {
            throw IntentError.invalidDate
        }

        let calendar = Calendar.current
        let days = max(
            0,
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: start),
                to: calendar.startOfDay(for: Date())
            ).day ?? 0
        )

        guard let template = UIImage(named: "template") else {
            throw IntentError.templateMissing
        }

        let image = ContentView.drawNumbers(on: template, days: days)

        // 保存到相册
        await saveToLibrary(image)

        // 通知主界面刷新预览
        NotificationCenter.default.post(
            name: .safetyDaysImageGenerated,
            object: nil,
            userInfo: ["image": image]
        )

        // 主线程弹分享面板（Siri 会拉起 App 到前台）
        await MainActor.run {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ShareSheetPresenter.present(image)
            }
        }

        return .result()
    }

    private func saveToLibrary(_ image: UIImage) async {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            try? await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }

        case .notDetermined:
            let granted = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if granted == .authorized || granted == .limited {
                try? await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
            }

        default:
            break
        }
    }
}