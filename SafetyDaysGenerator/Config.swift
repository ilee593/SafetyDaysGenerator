import Foundation

/// 应用配置 — 文案、起始日、配色都在这里
/// 改完 push 代码,GitHub Actions 会自动重新编译新的 IPA
enum AppConfig {
    // MARK: - 业务配置
    static let startDateString: String = "2023-05-18"            // 起始日
    static let title: String = "采购部安全零事件已经"              // 卡片主标题
    static let slogan: [String] = ["供应有保障", "安全要筑牢"]    // 气泡内两行标语
    static let company: String = "采购部"                        // 底部署名
    
    // MARK: - 颜色
    enum Color {
        static let headerOrangeStart = RGBA(r: 0xFF, g: 0x8A, b: 0x3D)
        static let headerOrangeEnd   = RGBA(r: 0xFF, g: 0x5A, b: 0x22)
        static let daysTagOrange     = RGBA(r: 0xFF, g: 0x5A, b: 0x22)
        static let barGray           = RGBA(r: 246, g: 246, b: 248)
        static let barOrange         = RGBA(r: 0xFF, g: 0x8A, b: 0x3D)
        static let bubbleRed         = RGBA(r: 0xFF, g: 0x3B, b: 0x30)
        static let textPrimary       = RGBA(r: 28,  g: 28,  b: 30)
        static let textSecondary     = RGBA(r: 142, g: 142, b: 147)
    }
    
    struct RGBA: Hashable {
        let r: Int, g: Int, b: Int
    }
    
    // MARK: - 计算起始日(用北京时区,避免跨时区天数差一天)
    static var startDate: Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return f.date(from: startDateString) ?? Date()
    }
}
