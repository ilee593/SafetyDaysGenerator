import Foundation

/// 日期 / 天数 / 星期工具
enum DayCounter {
    private static let beijing: TimeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
    
    static func today() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = beijing
        return calendar.startOfDay(for: Date())
    }
    
    /// 从 start 到 end 的天数差(包含 end 当天;start 当天为 0)
    static func daysBetween(start: Date, end: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = beijing
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        let comps = calendar.dateComponents([.day], from: s, to: e)
        return comps.day ?? 0
    }
    
    static func weekdayCN(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = beijing
        let names = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
        let w = calendar.component(.weekday, from: date)
        return names[w - 1]
    }
    
    static func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = beijing
        return f.string(from: date)
    }
}
