//
//  Capsule.swift
//  BuilderOS
//
//  Model for BuilderOS capsules
//

import Foundation

struct Capsule: Identifiable, Codable {
    let name: String
    let title: String
    let purpose: String

    // Use name as the unique identifier
    var id: String { name }

    // Convenience computed properties for UI
    var displayTitle: String { title }
    var displayDescription: String { purpose }
}

// MARK: - Mock data for preview
extension Capsule {
    static let mock = Capsule(
        name: "jellyfin-server-ops",
        title: "Jellyfin Server Operations",
        purpose: "Media server management and automation"
    )

    static let mockList = [
        mock,
        Capsule(
            name: "brandjack",
            title: "BrandJack",
            purpose: "Instagram brand monitoring and content automation"
        ),
        Capsule(
            name: "builderos-mobile",
            title: "BuilderOS Mobile",
            purpose: "iOS companion app for BuilderOS system"
        ),
        Capsule(
            name: "ecommerce",
            title: "E-Commerce Platform",
            purpose: "Shopify store and product management"
        )
    ]
}
