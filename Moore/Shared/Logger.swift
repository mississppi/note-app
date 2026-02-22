import Foundation

struct Logger {
    static func debug(_ message: String) {
        print("DEBUG: \(message)")
    }
    static func info(_ message: String) {
        print("INFO: \(message)")
    }
    static func warning(_ message: String) {
        print("WARNING: \(message)")
    }
    static func error(_ message: String) {
        print("ERROR: \(message)")
    }
}
