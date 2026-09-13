import SwiftUI

struct ContentView: View {
    @State private var days: Int = 0
    @State private var today: String = ""
    @State private var weekday: String = ""
    @State private var startWeekday: String = ""
    @State private var isSaving = false
    @State private var alertMessage: String?
    @State private var showShareSheet = false
    @State private var savedImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            // 顶部
            VStack(spacing: 6) {
                Text("起始日 \(AppConfig.startDateString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("今天 \(today) \(weekday)  ·  第 \(days) 天")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 60)
            .padding(.bottom, 8)

            // 海报预览
            PosterView(
                days: days,
                today: today,
                weekday: weekday,
                startDateString: AppConfig.startDateString,
                startWeekday: startWeekday,
                title: AppConfig.title,
                slogan: AppConfig.slogan,
                company: AppConfig.company
            )
            .scaleEffect(0.30)
            .aspectRatio(1080.0 / 1440.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
            )
            .padding(.horizontal, 20)

            Spacer(minLength: 8)

            // 按钮组
            VStack(spacing: 10) {
                Button(action: handleSave) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.down.fill")
                        }
                        Text(isSaving ? "保存中…" : "保存到相册")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.24),
                                        Color(red: 1.0, green: 0.30, blue: 0.13),
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .shadow(color: Color.orange.opacity(0.30), radius: 8, x: 0, y: 4)
                    )
                }
                .disabled(isSaving)

                if savedImage != nil {
                    Button(action: { showShareSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("分享到微信群")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.30, blue: 0.13))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0))
                        )
                    }
                }

                Text("每天点一下,自动生成当天卡片并保存到相册")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0).ignoresSafeArea())
        .onAppear(perform: refresh)
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("好") { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = savedImage {
                ShareSheet(items: [img])
            }
        }
    }

    private func refresh() {
        let now = DayCounter.today()
        days = DayCounter.daysBetween(start: AppConfig.startDate, end: now)
        today = DayCounter.dateString(now)
        weekday = DayCounter.weekdayCN(now)
        startWeekday = DayCounter.weekdayCN(AppConfig.startDate)
    }

    private func handleSave() {
        Task { @MainActor in
            isSaving = true
            defer { isSaving = false }
            let renderer = ImageRenderer(
                content: PosterView(
                    days: days,
                    today: today,
                    weekday: weekday,
                    startDateString: AppConfig.startDateString,
                    startWeekday: startWeekday,
                    title: AppConfig.title,
                    slogan: AppConfig.slogan,
                    company: AppConfig.company
                )
            )
            renderer.scale = 2.0
            guard let uiImage = renderer.uiImage else {
                alertMessage = "生成失败,请重试"
                return
            }
            savedImage = uiImage
            do {
                try PhotoSaver.save(image: uiImage)
                alertMessage = "已保存到相册 ✅\n去微信群发一下吧"
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - 分享面板
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
