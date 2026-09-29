import Foundation

let koreanUI = Locale.preferredLanguages.first?.hasPrefix("ko") ?? false
func tr(_ korean: String, _ english: String) -> String { koreanUI ? korean : english }
