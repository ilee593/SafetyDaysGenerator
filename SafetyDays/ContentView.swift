import SwiftUI
import UIKit
import Photos

struct ContentView: View {
    // 起始日期
    let startDate: Date = AppConfig.startDate

    @State private var daysCount: Int = 0
    @State private var titleText: String = AppConfig.defaultTitle
    @State private var unit: String = AppConfig.defaultUnit
    @State private var generatedImage: UIImage?
    @State private var showShare = false
    @State private var saveMessage: String?
    @State private var isSaving = false

    // 格式化日期
    private var startDateString: String {
        AppConfig.dateString(startDate)
    }
    private var todayDateString: String {
        AppConfig.dateString(AppConfig.today())
    }
    private var todayWeekdayCN: String {
        AppConfig.weekdayCN(AppConfig.today())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ===== 1. 顶部蓝色标题栏 =====
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("安全天数生成器")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("一键生成 · 自动计算 · 保存相册")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.08, green: 0.44, blue: 0.84))

                // ===== 2. 天数信息卡片 =====
                HStack(spacing: 0) {
                    // 起始日期
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("起始日期")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text(startDateString)
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    // 今天日期
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今天日期")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(todayDateString)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    // 已持续天数
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已持续天数")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(daysCount)")
                                .font(.system(size: 26, weight: .black))
                                .foregroundColor(.blue)
                            Text("天")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, 12)

                // ===== 3. 标题自定义 + 单位选择 =====
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("图片标题（可自定义）")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("输入标题", text: $titleText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 14))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("单位")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        HStack(spacing: 0) {
                            Button("天") { unit = "天" }
                                .font(.system(size: 14))
                                .foregroundColor(unit == "天" ? .white : .gray)
                                .frame(width: 44, height: 32)
                                .background(unit == "天" ? Color.blue : Color(.systemGray6))

                            Button("Days") { unit = "Days" }
                                .font(.system(size: 14))
                                .foregroundColor(unit == "Days" ? .white : .gray)
                                .frame(width: 44, height: 32)
                                .background(unit == "Days" ? Color.blue : Color(.systemGray6))
                        }
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, 12)

                // ===== 4. 生成按钮 =====
                Button(action: generateAndSave) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                        }
                        Text(isSaving ? "正在生成…" : "一键生成并保存到相册")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.08, green: 0.44, blue: 0.84))
                    .cornerRadius(12)
                    .padding(.horizontal, 12)
                }
                .disabled(isSaving)

                if let msg = saveMessage {
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(msg.hasPrefix("✅") ? .green : .red)
                        .padding(.horizontal, 12)
                }

                // ===== 5. 图片预览 =====
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.blue)
                        Text("图片预览")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .padding(.horizontal, 12)

                    if let img = generatedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 6)
                            .padding(.horizontal, 12)
                    } else {
                        // 占位符
                        ZStack {
                            Color(.systemGray6)
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.6))
                                Text("生成后显示在这里")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 220)
                        .cornerRadius(12)
                        .padding(.horizontal, 12)
                    }
                }

                // ===== 6. 底部提示 =====
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("生成的图片会自动保存到 iPhone 相册")
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            }
        }
        .onAppear(perform: calculateDays)
        .sheet(isPresented: $showShare) {
            if let img = generatedImage {
                ShareSheet(items: [img])
            }
        }
        .background(Color(.systemGray6))
    }

    // ===== 计算天数 =====
    func calculateDays() {
        daysCount = AppConfig.daysBetween(start: startDate, end: AppConfig.today())
    }

    // ===== 绘制卡片(1080×1440,与原设计验证稿一致) =====
    func renderCardImage() -> UIImage {
        let W: CGFloat = 1080
        let H: CGFloat = 1440

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: W, height: H), format: format)

        return renderer.image { rctx in
            let c = rctx.cgContext

            // ====== 背景白 ======
            c.setFillColor(UIColor.white.cgColor)
            c.fill(CGRect(x: 0, y: 0, width: W, height: H))

            // ====== 顶部橙色渐变横条 ======
            let headerH: CGFloat = 220
            let headerRect = CGRect(x: 0, y: 0, width: W, height: headerH)
            c.saveGState()
            c.addRect(headerRect)
            c.clip()
            let headerColors = [
                UIColor(red: 0xFF / 255.0, green: 0x8A / 255.0, blue: 0x3D / 255.0, alpha: 1.0).cgColor,
                UIColor(red: 0xFF / 255.0, green: 0x5A / 255.0, blue: 0x22 / 255.0, alpha: 1.0).cgColor,
            ] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: headerColors,
                                         locations: [0.0, 1.0]) {
                c.drawLinearGradient(gradient,
                                     start: CGPoint(x: 0, y: 0),
                                     end: CGPoint(x: W, y: 0),
                                     options: [])
            }
            c.restoreGState()

            // ====== 标题(白字,粗) ======
            let titleFont = UIFont.systemFont(ofSize: 54, weight: .bold)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white,
            ]
            (titleText as NSString).draw(at: CGPoint(x: 60, y: 50), withAttributes: titleAttrs)

            // ====== 起始日(白色半透明小字) ======
            let startText = "起始日 \(startDateString)  \(AppConfig.weekdayCN(startDate))"
            let startAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.88),
            ]
            (startText as NSString).draw(at: CGPoint(x: 60, y: 120), withAttributes: startAttrs)

            // ====== 大字天数(黑,粗) ======
            let daysStr = "\(daysCount)"
            let hugeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 360, weight: .heavy),
                .foregroundColor: UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0, alpha: 1.0),
            ]
            (daysStr as NSString).draw(at: CGPoint(x: 60, y: headerH + 90), withAttributes: hugeAttrs)

            // ====== "Days" 小橙标签(贴在大数字右上方) ======
            let tagText = "Days"
            let tagFont = UIFont.systemFont(ofSize: 42, weight: .bold)
            let tagSize = (tagText as NSString).size(withAttributes: [.font: tagFont])
            let tagBoxW = tagSize.width + 40
            let tagBoxH: CGFloat = 70
            let tagRect = CGRect(x: 60 + 540, y: headerH + 130, width: tagBoxW, height: tagBoxH)
            let tagPath = UIBezierPath(roundedRect: tagRect, cornerRadius: 14)
            c.setFillColor(UIColor(red: 0xFF / 255.0, green: 0x5A / 255.0, blue: 0x22 / 255.0, alpha: 1.0).cgColor)
            c.addPath(tagPath.cgPath)
            c.fillPath()
            let tagAttrs: [NSAttributedString.Key: Any] = [
                .font: tagFont,
                .foregroundColor: UIColor.white,
            ]
            (tagText as NSString).draw(
                at: CGPoint(x: tagRect.minX + (tagBoxW - tagSize.width) / 2,
                            y: tagRect.minY + (tagBoxH - tagSize.height) / 2 - 6),
                withAttributes: tagAttrs
            )

            // ====== 横向胶囊(标题 + 数字 + 单位) ======
            let barY: CGFloat = headerH + 470   // 690
            let barH: CGFloat = 110

            // 左侧灰底圆角矩形(标题)
            let leftBarRect = CGRect(x: 50, y: barY, width: 660, height: barH)
            let leftBarPath = UIBezierPath(roundedRect: leftBarRect, cornerRadius: 22)
            c.setFillColor(UIColor(red: 246 / 255.0, green: 246 / 255.0, blue: 248 / 255.0, alpha: 1.0).cgColor)
            c.addPath(leftBarPath.cgPath)
            c.fillPath()
            let barTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0, alpha: 1.0),
            ]
            (titleText as NSString).draw(at: CGPoint(x: 80, y: barY + (barH - 36) / 2),
                                         withAttributes: barTitleAttrs)

            // 右侧橙色圆角块(数字 + 单位)
            let rightBarRect = CGRect(x: 720, y: barY, width: 250, height: barH)
            let rightBarPath = UIBezierPath(roundedRect: rightBarRect, cornerRadius: 22)
            c.setFillColor(UIColor(red: 0xFF / 255.0, green: 0x8A / 255.0, blue: 0x3D / 255.0, alpha: 1.0).cgColor)
            c.addPath(rightBarPath.cgPath)
            c.fillPath()

            // 数字居中于 825,单位居中于 920;放不下时自动缩小
            let numCenterX: CGFloat = 825
            let unitCenterX: CGFloat = 920
            var numFontSize: CGFloat = unit == "天" ? 58 : 48
            var unitFontSize: CGFloat = unit == "天" ? 42 : 36
            var numW = (daysStr as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: numFontSize, weight: .bold)]).width
            var unitW = (unit as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: unitFontSize, weight: .bold)]).width
            while (numCenterX + numW / 2) > (unitCenterX - unitW / 2) && numFontSize > 20 {
                numFontSize -= 2
                unitFontSize = max(20, unitFontSize - 1)
                numW = (daysStr as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: numFontSize, weight: .bold)]).width
                unitW = (unit as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: unitFontSize, weight: .bold)]).width
            }
            let numFont = UIFont.systemFont(ofSize: numFontSize, weight: .bold)
            let unitFont = UIFont.systemFont(ofSize: unitFontSize, weight: .bold)
            let numSize = (daysStr as NSString).size(withAttributes: [.font: numFont])
            let unitSize = (unit as NSString).size(withAttributes: [.font: unitFont])
            let numAttrs: [NSAttributedString.Key: Any] = [
                .font: numFont,
                .foregroundColor: UIColor.white,
            ]
            let unitAttrs: [NSAttributedString.Key: Any] = [
                .font: unitFont,
                .foregroundColor: UIColor.white,
            ]
            (daysStr as NSString).draw(
                at: CGPoint(x: numCenterX - numSize.width / 2,
                            y: barY + (barH - numSize.height) / 2 - 6),
                withAttributes: numAttrs
            )
            (unit as NSString).draw(
                at: CGPoint(x: unitCenterX - unitSize.width / 2,
                            y: barY + (barH - unitSize.height) / 2 - 6),
                withAttributes: unitAttrs
            )

            // ====== 红色气泡(尾朝左下) ======
            let cx: CGFloat = W / 2
            let cy: CGFloat = 1040
            let r: CGFloat = 290

            // 先把尾巴区域填白(让气泡线只在尾巴外侧)
            let tail = [
                CGPoint(x: cx - r * 0.55, y: cy + r * 0.80),
                CGPoint(x: cx - r * 0.95, y: cy + r * 1.10),
                CGPoint(x: cx - r * 0.25, y: cy + r * 1.00),
            ]
            c.setFillColor(UIColor.white.cgColor)
            c.beginPath()
            c.move(to: tail[0])
            c.addLine(to: tail[1])
            c.addLine(to: tail[2])
            c.closePath()
            c.fillPath()

            // 气泡圆 + 尾巴描边
            c.setStrokeColor(UIColor(red: 0xFF / 255.0, green: 0x3B / 255.0, blue: 0x30 / 255.0, alpha: 1.0).cgColor)
            c.setLineWidth(22)
            c.setLineCap(.round)
            c.setLineJoin(.round)
            c.strokeEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            c.beginPath()
            c.move(to: tail[0])
            c.addLine(to: tail[1])
            c.addLine(to: tail[2])
            c.closePath()
            c.strokePath()

            // ====== 气泡内标语(两行) ======
            let sloganFont = UIFont.systemFont(ofSize: 74, weight: .bold)
            let sloganAttrs: [NSAttributedString.Key: Any] = [
                .font: sloganFont,
                .foregroundColor: UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0, alpha: 1.0),
            ]
            for (i, line) in AppConfig.slogan.enumerated() {
                let s = (line as NSString).size(withAttributes: sloganAttrs)
                (line as NSString).draw(
                    at: CGPoint(x: cx - s.width / 2, y: cy - 80 + CGFloat(i) * 110),
                    withAttributes: sloganAttrs
                )
            }

            // ====== 底部署名 ======
            let footerText = "\(AppConfig.company) · \(todayDateString) \(todayWeekdayCN)"
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .regular),
                .foregroundColor: UIColor(red: 142 / 255.0, green: 142 / 255.0, blue: 147 / 255.0, alpha: 1.0),
            ]
            let footerSize = (footerText as NSString).size(withAttributes: footerAttrs)
            (footerText as NSString).draw(
                at: CGPoint(x: cx - footerSize.width / 2, y: H - 80),
                withAttributes: footerAttrs
            )
        }
    }

    // ===== 生成图片并保存 =====
    func generateAndSave() {
        guard !isSaving else { return }
        isSaving = true
        saveMessage = nil

        calculateDays()
        let image = renderCardImage()
        generatedImage = image

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    isSaving = false
                    saveMessage = "❌ 未获得相册权限,请到 设置 → 隐私 → 照片 中开启"
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        isSaving = false
                        if success {
                            saveMessage = "✅ 已保存到相册"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showShare = true
                            }
                        } else {
                            saveMessage = "❌ 保存失败:\(error?.localizedDescription ?? "未知错误")"
                        }
                    }
                }
            }
        }
    }
}

// ===== 系统分享面板 =====
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}