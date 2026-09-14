import SwiftUI
import Photos

struct ContentView: View {
    // ===== 起始日期默认值（持久化） =====
    @AppStorage("defaultStartDate") private var defaultStartDateTimestamp: Double = {
        var comp = DateComponents()
        comp.year = 2023
        comp.month = 5
        comp.day = 18
        return Calendar.current.date(from: comp)!.timeIntervalSince1970
    }()

    @State private var startDate: Date = Date()
    @State private var todayDate: Date = Date()
    @State private var daysCount: Int = 0

    // ===== 标题 =====
    @AppStorage("defaultTitle") private var defaultTitle: String = "采购部安全零事件已经"
    @State private var titleText: String = ""

    // ===== 设置开关 =====
    @AppStorage("autoSave") private var autoSave: Bool = true
    @AppStorage("autoShare") private var autoShare: Bool = true

    // ===== 生成结果 =====
    @State private var generatedImage: UIImage?
    @State private var showShare = false
    @State private var saveMessage: String?
    @State private var showSettings = false

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
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.08, green: 0.44, blue: 0.84))

                // ===== 2. 天数信息卡片 =====
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("起始日期")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .scaleEffect(0.9, anchor: .leading)
                            .onChange(of: startDate) { _ in calculateDays() }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider().frame(height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("今天日期")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        DatePicker("", selection: $todayDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .scaleEffect(0.9, anchor: .leading)
                            .onChange(of: todayDate) { _ in calculateDays() }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider().frame(height: 40)

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

                // ===== 3. 图片标题 =====
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
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("一键生成并保存到相册")
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

                if let msg = saveMessage {
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(.green)
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
                        ZStack {
                            Color(.systemGray6)
                            Text("生成后显示在这里")
                                .foregroundColor(.gray)
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
        .onAppear {
            startDate = Date(timeIntervalSince1970: defaultStartDateTimestamp)
            titleText = defaultTitle
            calculateDays()
        }
        .sheet(isPresented: $showShare) {
            if let img = generatedImage {
                ShareSheet(items: [img])
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                defaultStartDateTimestamp: $defaultStartDateTimestamp,
                defaultTitle: $defaultTitle,
                autoSave: $autoSave,
                autoShare: $autoShare
            )
        }
        .background(Color(.systemGray6))
    }

    func calculateDays() {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: todayDate).day ?? 0
        daysCount = days
    }

    func generateAndSave() {
        calculateDays()

        guard let template = UIImage(named: "template") else {
            saveMessage = "❌ 找不到模板图片"
            return
        }

        let W = template.size.width
        let H = template.size.height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let renderer = UIGraphicsImageRenderer(size: template.size)
        let finalImage = renderer.image { ctx in
            template.draw(in: CGRect(origin: .zero, size: template.size))

            let daysText = "\(daysCount)"

            // 顶部虚线框
            let topAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: W * 0.10, weight: .black),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            daysText.draw(in: CGRect(x: W * 0.47, y: H * 0.10,
                                     width: W * 0.33, height: H * 0.09),
                          withAttributes: topAttrs)

            // 橙色条虚线框
            let orangeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: W * 0.055, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            daysText.draw(in: CGRect(x: W * 0.65, y: H * 0.245,
                                     width: W * 0.17, height: H * 0.05),
                          withAttributes: orangeAttrs)
        }

        generatedImage = finalImage

        if !autoSave {
            saveMessage = "✅ 已生成，请手动保存或分享"
            if autoShare { showShare = true }
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            saveMessage = "✅ 已保存到相册"
                            if autoShare {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showShare = true
                                }
                            }
                        } else {
                            saveMessage = "❌ 保存失败：\(error?.localizedDescription ?? "未知错误")"
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    saveMessage = "❌ 未获得相册权限，请到设置中开启"
                }
            }
        }
    }
}

// ===== 设置页 =====
struct SettingsView: View {
    @Binding var defaultStartDateTimestamp: Double
    @Binding var defaultTitle: String
    @Binding var autoSave: Bool
    @Binding var autoShare: Bool
    @Environment(\.presentationMode) var presentationMode

    @State private var tempStartDate: Date = Date()
    @State private var tempTitle: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("默认值")) {
                    DatePicker("默认起始日期", selection: $tempStartDate, displayedComponents: .date)
                    HStack {
                        Text("默认标题")
                        Spacer()
                        TextField("输入标题", text: $tempTitle)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section(header: Text("行为")) {
                    Toggle("生成后自动保存到相册", isOn: $autoSave)
                    Toggle("生成后自动弹出分享面板", isOn: $autoShare)
                }
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(
                trailing: Button("保存") {
                    defaultStartDateTimestamp = tempStartDate.timeIntervalSince1970
                    defaultTitle = tempTitle
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                tempStartDate = Date(timeIntervalSince1970: defaultStartDateTimestamp)
                tempTitle = defaultTitle
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
