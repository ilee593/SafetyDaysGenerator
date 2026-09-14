import Foundation

/// 应用配置 — 起始日、文案都在这里
/// 改完 push 代码,GitHub Actions 会自动重新编译新的 IPA
enum AppConfig {
    // MARK: - 业务配置(改这里即可)
    static let startDateString: String = "2023-05-18"              // 起始日
    static let defaultTitle: String = "采购部安全零事件已经"          // 卡片主标题
    static let slogan: [String] = ["供应有保障", "安全要筑牢"]       // 气泡内两行标语
    static let company: String = "采购部"                           // 底部署名
    static let defaultUnit: String = "天"                           // 默认单位(天 / Days)

    // MARK: - 时间计算(统一用北京时间,避免跨时区天数差一天)
    private static let beijing: TimeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

    /// 起始日(Date,北京时间)
    static var startDate: Date {
        let parts = startDateString.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return Date() }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = beijing
        return cal.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) ?? Date()
    }

    /// 今天(北京时间,取当天 0 点)
    static func today() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = beijing
        return cal.startOfDay(for: Date())
    }

    /// 从 start 到 end 的天数差(含 end 当天;start 当天为 0)
    static func daysBetween(start: Date, end: Date) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = beijing
        let s = cal.startOfDay(for: start)
        let e = cal.startOfDay(for: end)
        return cal.dateComponents([.day], from: s, to: e).day ?? 0
    }

    static func weekdayCN(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = beijing
        let names = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        return names[cal.component(.weekday, from: date) - 1]
    }

    static func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = beijing
        return f.string(from: date)
    }
}