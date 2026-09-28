import Foundation
import CoreFoundation

enum UsageError: Error {
    case unavailable, credentialsUnavailable, keychainDenied, expired, unauthorized
    case rateLimited(Date), connection, server(Int)
}

struct UsageSnapshot {
    let remaining: Int
    let used: Double
    let resetsAt: Date?
    let fetchedAt: Date
    let sessionRemaining: Int?
    let sessionResetsAt: Date?

    static func parse(_ result: [String: Any]) throws -> UsageSnapshot {
        guard let weekly = result["seven_day"] as? [String: Any],
              let used = percent(weekly["utilization"]) else { throw UsageError.unavailable }
        let session = result["five_hour"] as? [String: Any]
        return UsageSnapshot(remaining: remaining(used), used: max(0, min(100, used)),
            resetsAt: date(weekly["resets_at"]), fetchedAt: Date(),
            sessionRemaining: percent(session?["utilization"]).map(remaining),
            sessionResetsAt: date(session?["resets_at"]))
    }

    static func percent(_ value: Any?) -> Double? {
        guard let number = value as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(), number.doubleValue.isFinite else { return nil }
        return number.doubleValue
    }
    static func remaining(_ used: Double) -> Int { Int(max(0, min(100, 100 - used)).rounded(.down)) }
    static func date(_ value: Any?) -> Date? {
        guard let text = value as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: text) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text)
    }
}
