import UIKit

/// 海报视图 — 用 Core Graphics (CGContext) 绘制整个 1080×1440 海报
/// 数字位置严格按 "空白的模板.png" 的虚线框定位
class PosterView: UIView {
    private var days: Int = 0
    private var today: String = ""
    private var weekday: String = ""
    private var startWeekday: String = ""

    /// 海报逻辑尺寸(用于绘制,不论 view 在屏幕上多大,绘制都按这个尺寸)
    static let posterSize = CGSize(width: 1080, height: 1440)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentMode = .redraw
        isOpaque = true
        clearsContextBeforeDrawing = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 更新数据并触发重绘
    func update(days: Int, today: String, weekday: String, startWeekday: String) {
        self.days = days
        self.today = today
        self.weekday = weekday
        self.startWeekday = startWeekday
        setNeedsDisplay()
    }

    /// 把整张海报渲染成 UIImage(固定 1080×1440)用于保存到相册
    func renderAsImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: PosterView.posterSize, format: format)
        return renderer.image { ctx in
            drawPoster(in: CGRect(origin: .zero, size: PosterView.posterSize), ctx: ctx.cgContext)
        }
    }

    // 屏幕上的视图按 view 实际尺寸缩放绘制
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let scaleX = bounds.width / PosterView.posterSize.width
        let scaleY = bounds.height / PosterView.posterSize.height
        let scale = min(scaleX, scaleY)
        ctx.saveGState()
        ctx.scaleBy(x: scale, y: scale)
        drawPoster(in: CGRect(origin: .zero, size: PosterView.posterSize), ctx: ctx)
        ctx.restoreGState()
    }

    // MARK: - Core Graphics 绘制逻辑
    private func drawPoster(in rect: CGRect, ctx: CGContext) {
        let W = rect.width    // 1080
        let H = rect.height   // 1440

        // ====== 背景白 ======
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(rect)

        // ====== 顶部橙色渐变条 ======
        let headerH: CGFloat = 220
        let headerRect = CGRect(x: 0, y: 0, width: W, height: headerH)
        ctx.saveGState()
        ctx.addRect(headerRect)
        ctx.clip()
        let headerColors = [
            UIColor(red: 0xFF/255.0, green: 0x8A/255.0, blue: 0x3D/255.0).cgColor,
            UIColor(red: 0xFF/255.0, green: 0x5A/255.0, blue: 0x22/255.0).cgColor,
        ] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: headerColors,
                                  locations: [0.0, 1.0])!
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: W, y: 0),
                               options: [])
        ctx.restoreGState()

        // ====== 标题(白字) ======
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 54, weight: .semibold),
            .foregroundColor: UIColor.white,
        ]
        let titleSize = (AppConfig.title as NSString).size(withAttributes: titleAttrs)
        (AppConfig.title as NSString).draw(at: CGPoint(x: 60, y: 50), withAttributes: titleAttrs)

        // ====== 起始日 ======
        let startText = "起始日 \(AppConfig.startDateString)  \(startWeekday)"
        let startAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.88),
        ]
        (startText as NSString).draw(at: CGPoint(x: 60, y: 50 + titleSize.height + 14), withAttributes: startAttrs)

        // ====== 大字数字(模板右上角虚线框位置) ======
        let daysStr = "\(days)"
        let daysAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 360, weight: .heavy),
            .foregroundColor: UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0),
        ]
        let daysX: CGFloat = 60
        let daysY: CGFloat = headerH + 90
        (daysStr as NSString).draw(at: CGPoint(x: daysX, y: daysY), withAttributes: daysAttrs)

        // ====== "Days" 小橙标签(贴在大数字右上方,虚线框位置) ======
        let labelText = "Days"
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 42, weight: .bold),
            .foregroundColor: UIColor.white,
        ]
        let labelSize = (labelText as NSString).size(withAttributes: labelAttrs)
        let labelBoxW = labelSize.width + 44
        let labelBoxH: CGFloat = 70
        let labelX: CGFloat = daysX + 540
        let labelY: CGFloat = daysY + 20
        let labelBoxRect = CGRect(x: labelX, y: labelY, width: labelBoxW, height: labelBoxH)
        let labelPath = UIBezierPath(roundedRect: labelBoxRect, cornerRadius: 14)
        ctx.setFillColor(UIColor(red: 0xFF/255.0, green: 0x5A/255.0, blue: 0x22/255.0, alpha: 1.0).cgColor)
        ctx.addPath(labelPath.cgPath)
        ctx.fillPath()
        let labelTextX = labelX + (labelBoxW - labelSize.width) / 2
        let labelTextY = labelY + (labelBoxH - labelSize.height) / 2
        (labelText as NSString).draw(at: CGPoint(x: labelTextX, y: labelTextY), withAttributes: labelAttrs)

        // ====== 横向胶囊(标题 + 数字 + 天) ======
        let barY: CGFloat = headerH + 470
        let barH: CGFloat = 110

        // 左侧灰色圆角矩形(标题)
        let leftBarRect = CGRect(x: 50, y: barY, width: 660, height: barH)
        let leftBarPath = UIBezierPath(roundedRect: leftBarRect, cornerRadius: 22)
        ctx.setFillColor(UIColor(red: 246/255.0, green: 246/255.0, blue: 248/255.0, alpha: 1.0).cgColor)
        ctx.addPath(leftBarPath.cgPath)
        ctx.fillPath()
        let barTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .semibold),
            .foregroundColor: UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0),
        ]
        (AppConfig.title as NSString).draw(
            at: CGPoint(x: 80, y: barY + (barH - 36) / 2),
            withAttributes: barTitleAttrs
        )

        // 右侧橙色块(模板虚线框位置)
        let rightBarRect = CGRect(x: 720, y: barY, width: 250, height: barH)
        let rightBarPath = UIBezierPath(roundedRect: rightBarRect, cornerRadius: 22)
        ctx.setFillColor(UIColor(red: 0xFF/255.0, green: 0x8A/255.0, blue: 0x3D/255.0, alpha: 1.0).cgColor)
        ctx.addPath(rightBarPath.cgPath)
        ctx.fillPath()

        // 数字 + "天"
        let numAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 58, weight: .bold),
            .foregroundColor: UIColor.white,
        ]
        let numSize = ("\(days)" as NSString).size(withAttributes: numAttrs)
        ("\(days)" as NSString).draw(
            at: CGPoint(x: 720 + 105 - numSize.width / 2, y: barY + (barH - numSize.height) / 2),
            withAttributes: numAttrs
        )
        let tianAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 42, weight: .medium),
            .foregroundColor: UIColor.white,
        ]
        let tianSize = ("天" as NSString).size(withAttributes: tianAttrs)
        ("天" as NSString).draw(
            at: CGPoint(x: 720 + 200 - tianSize.width / 2, y: barY + (barH - tianSize.height) / 2),
            withAttributes: tianAttrs
        )

        // ====== 红色气泡 ======
        let cx = W / 2
        let cy: CGFloat = 1040
        let r: CGFloat = 290

        // 先把尾巴区域填白(让气泡线只在尾巴外侧)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: cx - r * 0.55, y: cy + r * 0.80))
        ctx.addLine(to: CGPoint(x: cx - r * 0.95, y: cy + r * 1.10))
        ctx.addLine(to: CGPoint(x: cx - r * 0.25, y: cy + r * 1.00))
        ctx.closePath()
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillPath()

        // 气泡圆 + 尾巴描边
        ctx.setStrokeColor(UIColor(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0, alpha: 1.0).cgColor)
        ctx.setLineWidth(22)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.strokeEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        ctx.beginPath()
        ctx.move(to: CGPoint(x: cx - r * 0.55, y: cy + r * 0.80))
        ctx.addLine(to: CGPoint(x: cx - r * 0.95, y: cy + r * 1.10))
        ctx.addLine(to: CGPoint(x: cx - r * 0.25, y: cy + r * 1.00))
        ctx.closePath()
        ctx.strokePath()

        // ====== 气泡内标语(两行) ======
        let sloganAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 74, weight: .bold),
            .foregroundColor: UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0),
        ]
        let s0Size = (AppConfig.slogan[0] as NSString).size(withAttributes: sloganAttrs)
        (AppConfig.slogan[0] as NSString).draw(
            at: CGPoint(x: cx - s0Size.width / 2, y: cy - 80),
            withAttributes: sloganAttrs
        )
        let s1Size = (AppConfig.slogan[1] as NSString).size(withAttributes: sloganAttrs)
        (AppConfig.slogan[1] as NSString).draw(
            at: CGPoint(x: cx - s1Size.width / 2, y: cy + 30),
            withAttributes: sloganAttrs
        )

        // ====== 底部署名 ======
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .regular),
            .foregroundColor: UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0),
        ]
        let footerText = "\(AppConfig.company) · \(today) \(weekday)"
        let footerSize = (footerText as NSString).size(withAttributes: footerAttrs)
        (footerText as NSString).draw(
            at: CGPoint(x: cx - footerSize.width / 2, y: H - 80),
            withAttributes: footerAttrs
        )
    }
}
