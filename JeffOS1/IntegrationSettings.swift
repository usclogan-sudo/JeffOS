import Foundation

enum IntegrationSettings {
    static var graphAccessToken: String {
        ProcessInfo.processInfo.environment["MICROSOFT_GRAPH_ACCESS_TOKEN"] ?? ""
    }

    static var anthropicAPIKey: String {
        ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    static var asanaAccessToken: String {
        ProcessInfo.processInfo.environment["ASANA_ACCESS_TOKEN"] ?? ""
    }

    static var asanaProjectGID: String {
        ProcessInfo.processInfo.environment["ASANA_PROJECT_GID"] ?? ""
    }

    static var workEmail: String {
        ProcessInfo.processInfo.environment["JEFF_WORK_EMAIL"] ?? "jeff@pelorushx.com"
    }

    static var graphConfigured: Bool { !graphAccessToken.isEmpty }
    static var claudeConfigured: Bool { !anthropicAPIKey.isEmpty }
    static var asanaConfigured: Bool {
        !asanaAccessToken.isEmpty && !asanaProjectGID.isEmpty
    }
}
