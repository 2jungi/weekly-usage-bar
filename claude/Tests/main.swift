import Foundation

var checks = 0
func expect(_ condition: @autoclosure () -> Bool, _ name: String) {
    guard condition() else { fatalError("FAIL: \(name)") }
    checks += 1
}
func expectUnavailable(_ value: [String: Any], _ name: String) {
    do { _ = try UsageSnapshot.parse(value); fatalError("FAIL: \(name)") }
    catch UsageError.unavailable { checks += 1 }
    catch { fatalError("Unexpected error: \(error)") }
}
func window(_ used: Any, _ date: Any = "2026-10-02T14:00:00.355759+00:00") -> [String: Any] {
    ["utilization": used, "resets_at": date]
}
let parsed = try UsageSnapshot.parse(["seven_day": window(78), "five_hour": window(100)])
expect(parsed.remaining == 22, "weekly remaining, not session remaining")
expect(parsed.sessionRemaining == 0, "separate five-hour window")
expect(parsed.resetsAt != nil, "fractional ISO timestamp")
expect(UsageSnapshot.date("2026-10-02T14:00:00Z") != nil, "whole-second ISO timestamp")
expect(try! UsageSnapshot.parse(["seven_day": window(78.2)]).remaining == 21, "round down")
expect(try! UsageSnapshot.parse(["seven_day": window(110)]).remaining == 0, "lower clamp")
expect(try! UsageSnapshot.parse(["seven_day": window(-1)]).remaining == 100, "upper clamp")
expect(try! UsageSnapshot.parse(["seven_day": window(1e100)]).used == 100, "safe extreme value")
expect(try! UsageSnapshot.parse(["seven_day": window(0, NSNull())]).resetsAt == nil, "null reset supported")
expect(try! UsageSnapshot.parse(["seven_day": window(20)]).sessionRemaining == nil, "missing session is not unlimited")
expectUnavailable(["seven_day_sonnet": window(0)], "do not substitute model-specific quota")
expectUnavailable(["five_hour": window(30)], "do not substitute five-hour quota")
expectUnavailable(["seven_day": ["resets_at": NSNull()]], "missing percentage is unknown")
expectUnavailable(["seven_day": window(true)], "boolean is not a usage percentage")
expectUnavailable(["seven_day": window(Double.infinity)], "nonfinite usage rejected")
let now = Date(timeIntervalSince1970: 0)
expect(UsageReader.retryDate(nil, now: now).timeIntervalSince1970 == 300, "default cooldown")
expect(UsageReader.retryDate("60", now: now).timeIntervalSince1970 == 300, "minimum cooldown")
expect(UsageReader.retryDate("3600", now: now).timeIntervalSince1970 == 3600, "respect Retry-After seconds")
expect(UsageReader.retryDate("Thu, 01 Jan 1970 01:00:00 GMT", now: now).timeIntervalSince1970 == 3600, "respect Retry-After date")
expect(UsageReader.retryDate("not a date", now: now).timeIntervalSince1970 == 300, "invalid Retry-After")
print("PASS: \(checks) weekly/session parsing and retry checks")
