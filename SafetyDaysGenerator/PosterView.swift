import SwiftUI

// MARK: - 海报视图(1080×1440,3:4,适合微信群发图)
// 用 SwiftUI 文字 + offset 精确布局,ImageRenderer 渲染为 PNG
struct PosterView: View {
    let days: Int
    let today: String
    let weekday: String
    let startDateString: String
    let startWeekday: String
    let title: String
    let slogan: [String]
    let company: String

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
            VStack(spacing: 0) {
                headerBar
                mainContent
                bubble
                Spacer(minLength: 0)
                footer
            }
        }
        .frame(width: 1080, height: 1440)
        .environment(\.colorScheme, .light)
    }

    // 顶部橙色条
    private var headerBar: some View {
        LinearGradient(
            colors: [
                Color(red: 0xFF/255.0, green: 0x8A/255.0, blue: 0x3D/255.0),
                Color(red: 0xFF/255.0, green: 0x5A/255.0, blue: 0x22/255.0),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 220)
        .overlay(
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: true, vertical: false)
                Text("起始日 \(startDateString)  \(startWeekday)")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.88))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 60),
            alignment: .center
        )
    }

    // 中间数字 + 横向胶囊
    private var mainContent: some View {
        VStack(spacing: 0) {
            // 大数字 + Days 标签(用 offset 精确定位)
            ZStack(alignment: .topLeading) {
                Color.white
                    .frame(height: 480)

                // 大数字
                Text("\(days)")
                    .font(.system(size: 360, weight: .heavy))
                    .foregroundColor(Color(red: 28/255.0, green: 28/255.0, blue: 30/255.0))
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(x: 60, y: 30)

                // "Days" 小橙标签
                Text("Days")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0xFF/255.0, green: 0x5A/255.0, blue: 0x22/255.0))
                    )
                    .offset(x: 600, y: 110)
            }
            .frame(height: 480)

            // 横向胶囊
            HStack(spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(Color(red: 28/255.0, green: 28/255.0, blue: 30/255.0))
                        .padding(.leading, 30)
                    Spacer(minLength: 0)
                }
                .frame(width: 660, height: 110)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(red: 246/255.0, green: 246/255.0, blue: 248/255.0))
                )

                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text("\(days)")
                        .font(.system(size: 58, weight: .bold))
                        .foregroundColor(.white)
                    Spacer().frame(width: 24)
                    Text("天")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundColor(.white)
                    Spacer(minLength: 0)
                }
                .frame(width: 250, height: 110)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(red: 0xFF/255.0, green: 0x8A/255.0, blue: 0x3D/255.0))
                )
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
        }
    }

    // 红色气泡
    private var bubble: some View {
        ZStack {
            SpeechBubbleShape()
                .stroke(
                    Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0),
                    style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 620, height: 620)

            VStack(spacing: 30) {
                Text(slogan[0])
                    .font(.system(size: 74, weight: .bold))
                    .foregroundColor(Color(red: 28/255.0, green: 28/255.0, blue: 30/255.0))
                Text(slogan[1])
                    .font(.system(size: 74, weight: .bold))
                    .foregroundColor(Color(red: 28/255.0, green: 28/255.0, blue: 30/255.0))
            }
        }
        .frame(width: 720, height: 720)
        .padding(.top, 40)
    }

    // 底部
    private var footer: some View {
        Text("\(company) · \(today) \(weekday)")
            .font(.system(size: 28))
            .foregroundColor(Color(red: 142/255.0, green: 142/255.0, blue: 147/255.0))
            .padding(.top, 10)
            .padding(.bottom, 50)
    }
}

// MARK: - 气泡形状(圆 + 左下小尾巴,组合成连续描边)
struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2 - 10
        let cx = rect.midX
        let cy = rect.midY

        var path = Path()

        // 主体椭圆
        path.addEllipse(in: CGRect(
            x: cx - r, y: cy - r,
            width: r * 2, height: r * 2
        ))

        // 尾巴(从圆左下延伸出来,形成连续轮廓)
        let p1 = CGPoint(x: cx - r * 0.55, y: cy + r * 0.78)
        let p2 = CGPoint(x: cx - r * 0.98, y: cy + r * 1.10)
        let p3 = CGPoint(x: cx - r * 0.20, y: cy + r * 1.02)

        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p1)
        path.closeSubpath()

        return path
    }
}
