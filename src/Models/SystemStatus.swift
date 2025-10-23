//
//  SystemStatus.swift
//  BuilderOS
//
//  Model for BuilderOS system status
//

import Foundation

struct SystemStatus: Codable {
    let version: String
    let uptime: TimeInterval
    let capsulesCount: Int
    let activeCapsulesCount: Int
    let lastAuditTime: Date?
    let healthStatus: HealthStatus
    let services: [ServiceStatus]

    enum HealthStatus: String, Codable {
        case healthy = "healthy"
        case degraded = "degraded"
        case down = "down"

        var displayName: String {
            rawValue.capitalized
        }

        var color: String {
            switch self {
            case .healthy: return "green"
            case .degraded: return "orange"
            case .down: return "red"
            }
        }
    }

    struct ServiceStatus: Codable, Identifiable {
        let id: String
        let name: String
        let isRunning: Bool
        let port: Int?

        var displayStatus: String {
            isRunning ? "Running" : "Stopped"
        }
    }

    var uptimeFormatted: String {
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Mock data for preview
extension SystemStatus {
    static let mock = SystemStatus(
        version: "2.1.0",
        uptime: 245678, // ~68 hours
        capsulesCount: 25,
        activeCapsulesCount: 7,
        lastAuditTime: Date().addingTimeInterval(-3600),
        healthStatus: .healthy,
        services: [
            ServiceStatus(id: "api", name: "BuilderOS API", isRunning: true, port: 8080),
            ServiceStatus(id: "n8n", name: "n8n Workflows", isRunning: true, port: 5678),
            ServiceStatus(id: "memory", name: "Memory Service", isRunning: true, port: nil)
        ]
    )
}
