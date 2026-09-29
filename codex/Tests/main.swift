import Foundation

var checks = 0
func expect(_ condition: @autoclosure () -> Bool, _ name: String) {
    guard condition() else { fatalError("FAIL: \(name)") }
    checks += 1
}
func expectUnavailable(_ result: [String: Any], _ name: String) {
    do { _ = try UsageSnapshot.parse(result); fatalError("FAIL: \(name)") }
    catch UsageError.unavailable { checks += 1 }
    catch { fatalError("Unexpected error: \(error)") }
}
func window(_ used: Double, _ minutes: Int = 10080) -> [String: Any] {
    ["usedPercent": used, "windowDurationMins": minutes, "resetsAt": 1_900_000_000.0]
}
func bucket(_ primary: [String: Any], _ secondary: [String: Any]? = nil) -> [String: Any] {
    var result: [String: Any] = ["limitId": "codex", "primary": primary]
    if let secondary = secondary { result["secondary"] = secondary }
    return result
}
func response(_ primary: [String: Any], _ secondary: [String: Any]? = nil) -> [String: Any] {
    ["rateLimitsByLimitId": ["codex": bucket(primary, secondary)]]
}
let primary = try UsageSnapshot.parse(response(window(56)))
expect(primary.remaining == 44, "weekly primary")
expect(primary.resetsAt?.timeIntervalSince1970 == 1_900_000_000, "Unix seconds")
expect(try! UsageSnapshot.parse(response(window(5, 300), window(62))).remaining == 38, "weekly secondary, not five-hour quota")
expect(try! UsageSnapshot.parse(["rateLimits": bucket(window(25))]).remaining == 75, "legacy response")
expect(try! UsageSnapshot.parse(response(window(56.2))).remaining == 43, "do not overstate fractional balance")
expect(try! UsageSnapshot.parse(response(window(1e100))).used == 100, "extreme usage cannot overflow menu formatting")
expect(try! UsageSnapshot.parse(response(window(-10))).remaining == 100, "upper clamp")
expectUnavailable(response(window(50, 300)), "short window alone is not weekly")
expectUnavailable(response(["windowDurationMins": 10080]), "missing usage is not zero")
expectUnavailable(response(window(.infinity)), "reject nonfinite usage")
expectUnavailable([:], "empty response")
expectUnavailable(["rateLimitsByLimitId": ["base_model_inference": bucket(window(0))], "rateLimits": bucket(window(0))], "do not fall back to reserve bucket")
expectUnavailable(["rateLimits": ["limitId": "base_model_inference", "primary": window(0)]], "reject named non-Codex legacy quota")
let mapped = try UsageSnapshot.parse(["rateLimitsByLimitId": ["codex": bucket(window(56)), "base_model_inference": bucket(window(0))], "rateLimits": bucket(window(99))])
expect(mapped.remaining == 44, "named Codex bucket wins")
print("PASS: \(checks) quota parsing checks")
