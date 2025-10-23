//
//  Capsule.swift
//  BuilderOS
//
//  Model for BuilderOS capsules
//

import Foundation

struct Capsule: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let status: CapsuleStatus
    let createdAt: Date
    let updatedAt: Date
    let path: String
    let tags: [String]

    enum CapsuleStatus: String, Codable {
        case active = "active"
        case development = "development"
        case archived = "archived"
        case testing = "testing"

        var displayName: String {
            rawValue.capitalized
        }

        var color: String {
            switch self {
            case .active: return "green"
            case .development: return "blue"
            case .archived: return "gray"
            case .testing: return "orange"
            }
        }
    }
}

// MARK: - Mock data for preview
extension Capsule {
    static let mock = Capsule(
        id: "jellyfin-server-ops",
        name: "Jellyfin Server Ops",
        description: "Media server management and automation",
        status: .active,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date().addingTimeInterval(-86400),
        path: "/Users/Ty/BuilderOS/capsules/jellyfin-server-ops",
        tags: ["media", "server", "automation"]
    )

    static let mockList = [
        mock,
        Capsule(
            id: "brandjack",
            name: "BrandJack",
            description: "Instagram brand monitoring and content automation",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date().addingTimeInterval(-3600),
            path: "/Users/Ty/BuilderOS/capsules/brandjack",
            tags: ["instagram", "social", "automation"]
        ),
        Capsule(
            id: "ecommerce",
            name: "E-Commerce Platform",
            description: "Shopify store and product management",
            status: .development,
            createdAt: Date().addingTimeInterval(-86400 * 15),
            updatedAt: Date().addingTimeInterval(-1800),
            path: "/Users/Ty/BuilderOS/capsules/ecommerce",
            tags: ["shopify", "ecommerce", "store"]
        )
    ]
}
