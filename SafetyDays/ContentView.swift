import SwiftUI
import UIKit
import Photos

struct ContentView: View {

    // MARK: - 持久化设置

    @AppStorage("defaultStartDate")
    private var defaultStartDateString: String = "2023-05-18"

    @AppStorage("defaultTitle")
    private var defaultTitle: String = "采购部安全零事件已经"

    @AppStorage("autoSave")
    private var autoSave: Bool = true

    @AppStorage("autoShare")
    private var autoShare: Bool = false

    // MARK: - 主界面状态

    @State private var startDate: Date = ContentView.defaultStartDate()
    @State private var todayDate: Date = Calendar.current.startOfDay(for: Date())

    @State private var imageTitle: String = "采购部安全零事件已经"

    @State private var generatedImage: UIImage?

    @State private var showingSettings = false
    @State private var showingShareSheet = false

    @State private var shareImage: UIImage?

    @State private var isGenerating = false

    // MARK: - 日期格式

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - 默认起始日期

    private static func defaultStartDate() -> Date {
        dateFormatter.date(from: "2023-05-18")
        ?? Calendar.current.startOfDay(for: Date())
    }

    // MARK: - 天数

    private var days: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: todayDate)
        let difference = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(0, difference)
    }

    // MARK: - 日期字符串

    private var startDateText: String {
        Self.dateFormatter.string(from: startDate)
    }

    private var todayDateText: String {
        Self.dateFormatter.string(from: todayDate)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerBar
                dateInformationCard
                titleCard
                generateButton
                if let msg = saveMessage {
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                previewSection
                footerHint
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                defaultStartDateString: $defaultStartDateString,
                defaultTitle: $defaultTitle,
                autoSave: $autoSave,
                autoShare: $autoShare
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
        .onAppear {
            loadStoredSettings()
            todayDate = Calendar.current.startOfDay(for: Date())
        }
        .onChange(of: defaultStartDateString) { newValue in
            if let date = Self.dateFormatter.date(from: newValue) {
                startDate = date
            }
        }
        .onChange(of: defaultTitle) { newValue in
            imageTitle = newValue
        }
    }

    // MARK: - 顶部蓝色标题栏（替代 NavigationView + toolbar）

    private var headerBar: some View {
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
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.08, green: 0.44, blue: 0.84))
    }

    // MARK: - 日期信息卡片

    private var dateInformationCard: some View {
        HStack(spacing: 0) {
            startDateColumn
            Divider().frame(height: 40)
            todayDateColumn
            Divider().frame(height: 40)
            daysCountColumn
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    private var startDateColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("起始日期")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var todayDateColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("今天日期")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            DatePicker("", selection: $todayDate, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var daysCountColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("已持续天数")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(days)")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.blue)
                Text("天")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 标题卡片

    private var titleCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "doc.text.fill")
                .foregroundColor(.blue)
                .font(.system(size: 22))
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 8) {
                Text("图片标题（可自定义）")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                TextField("请输入图片标题", text: $imageTitle)
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - 生成按钮

    private var generateButton: some View {
        Button {
            generateImage()
        } label: {
            HStack(spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 18, weight: .bold))
                }
                Text("一键生成并保存到相册")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(red: 0.08, green: 0.44, blue: 0.84))
            .cornerRadius(12)
        }
        .disabled(isGenerating)
    }

    // MARK: - 预览

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "photo.fill")
                    .foregroundColor(.blue)
                Text("图片预览")
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 4)
            previewImage
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 6)
        }
    }

    @ViewBuilder
    private var previewImage: some View {
        if let image = generatedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.12))
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 42))
                        .foregroundColor(.gray)
                    Text("生成后显示在这里")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            .aspectRatio(1024.0 / 1536.0, contentMode: .fit)
        }
    }

    // MARK: - 底部提示

    private var footerHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
            Text("生成的图片会自动保存到 iPhone 相册。")
        }
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }

    // MARK: - 加载设置

    private func loadStoredSettings() {
        if let date = Self.dateFormatter.date(from: defaultStartDateString) {
            startDate = date
        } else {
            startDate = Self.defaultStartDate()
        }
        imageTitle = defaultTitle
    }

    // MARK: - 生成图片

    private func generateImage() {
        guard !isGenerating else { return }
        isGenerating = true

        DispatchQueue.main.async {
            guard let template = UIImage(named: "template") else {
                isGenerating = false
                return
            }

            let image = Self.drawNumbers(on: template, days: days)
            generatedImage = image
            isGenerating = false

            if autoSave {
                saveToPhotoLibrary(image)
            }

            if autoShare {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shareImage = image
                    showingShareSheet = true
                }
            }
        }
    }

    // MARK: - 状态文案

    private var saveMessage: String? {
        if let img = generatedImage {
            return "✅ 已生成预览（自动保存：\(autoSave ? "开" : "关"))"
        }
        return nil
    }

    // MARK: - 图片绘制

    static func drawNumbers(on image: UIImage, days: Int) -> UIImage {

        let imageSize = image.size

        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let result = renderer.image { context in

            image.draw(in: CGRect(origin: .zero, size: imageSize))

            let topRect = CGRect(
                x: imageSize.width * 0.47,
                y: imageSize.height * 0.10,
                width: imageSize.width * 0.33,
                height: imageSize.height * 0.09
            )

            let topFontSize = topRect.width * 0.10

            drawCenteredText(
                "\(days)",
                in: topRect,
                fontSize: topFontSize,
                color: .black,
                context: context
            )

            let orangeRect = CGRect(
                x: imageSize.width * 0.65,
                y: imageSize.height * 0.245,
                width: imageSize.width * 0.17,
                height: imageSize.height * 0.05
            )

            let orangeFontSize = orangeRect.width * 0.055

            drawCenteredText(
                "\(days)",
                in: orangeRect,
                fontSize: orangeFontSize,
                color: .white,
                context: context
            )
        }

        return result
    }

    // MARK: - 居中文字

    private static func drawCenteredText(
        _ text: String,
        in rect: CGRect,
        fontSize: CGFloat,
        color: UIColor,
        context: UIGraphicsImageRendererContext
    ) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byClipping

        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)

        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: rect.width, height: rect.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let drawRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y + (rect.height - boundingRect.height) / 2.0,
            width: rect.width,
            height: rect.height
        )

        attributedString.draw(in: drawRect)
    }

    // MARK: - 保存照片

    private func saveToPhotoLibrary(_ image: UIImage) {

        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            performPhotoSave(image)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        performPhotoSave(image)
                    }
                }
            }

        default:
            break
        }
    }

    private func performPhotoSave(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { _, _ in
            // 故意不弹 Alert
        }
    }
}


// MARK: - 设置页面

struct SettingsView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Binding var defaultStartDateString: String
    @Binding var defaultTitle: String
    @Binding var autoSave: Bool
    @Binding var autoShare: Bool

    @State private var selectedDate: Date = SettingsView.defaultDate()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func defaultDate() -> Date {
        dateFormatter.date(from: "2023-05-18") ?? Date()
    }

    var body: some View {
        NavigationView {
            settingsForm
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            defaultStartDateString = Self.dateFormatter.string(from: selectedDate)
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            if let date = Self.dateFormatter.date(from: defaultStartDateString) {
                selectedDate = date
            }
        }
    }

    private var settingsForm: some View {
        Form {
            Section("默认值") {
                DatePicker(
                    "默认起始日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .onChange(of: selectedDate) { newValue in
                    defaultStartDateString = Self.dateFormatter.string(from: newValue)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("默认标题")
                        .font(.system(size: 14, weight: .medium))
                    TextField("默认图片标题", text: $defaultTitle)
                }
            }

            Section("行为") {
                Toggle("生成后自动保存到相册", isOn: $autoSave)
                Toggle("生成后自动弹出分享面板", isOn: $autoShare)
            }

            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


// MARK: - 系统分享面板

struct ShareSheet: UIViewControllerRepresentable {

    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
