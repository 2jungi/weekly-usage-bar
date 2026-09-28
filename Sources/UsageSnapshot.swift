import Foundation

struct UsageSnapshot {
    let remaining: Int
    let used: Double
    let resetsAt: Date?
    let fetchedAt: Date

    static func parse(_ result: [String: Any]) throws -> UsageSnapshot {
        let buckets = result["rateLimitsByLimitId"] as? [String: [String: Any]]
        let legacy = result["rateLimits"] as? [String: Any]
        // Prefer the named bucket; do not accidentally show a reserve model's quota.
        let bucket: [String: Any]?
        if let buckets = buckets, !buckets.isEmpty {
            bucket = buckets["codex"]
        } else if let legacy = legacy,
                  legacy["limitId"] == nil || legacy["limitId"] is NSNull || (legacy["limitId"] as? String) == "codex" {
            bucket = legacy
        } else {
            bucket = nil
        }
        guard let bucket = bucket,
              let window = [bucket["primary"], bucket["secondary"]]
                .compactMap({ $0 as? [String: Any] })
                .first(where: { ($0["windowDurationMins"] as? Int) == 10080 }),
              let used = window["usedPercent"] as? Double, used.isFinite else {
            throw UsageError.unavailable
        }
        let reset = (window["resetsAt"] as? Double).map { Date(timeIntervalSince1970: $0) }
        return UsageSnapshot(remaining: Int(max(0, min(100, 100 - used)).rounded(.down)),
                             used: max(0, min(100, used)), resetsAt: reset, fetchedAt: Date())
    }
}

enum UsageError: Error { case unavailable, missingCLI, connection }
