import Foundation
import Security

/// Secure storage manager for sensitive data using iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Public Methods

    /// Store a string value in Keychain
    /// - Parameters:
    ///   - key: Unique identifier for the value
    ///   - value: String value to store
    func set(key: String, value: String) {
        guard let data = value.data(using: .utf8) else {
            print("❌ KeychainManager: Failed to encode value for key '\(key)'")
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("❌ KeychainManager: Failed to save key '\(key)' - Status: \(status)")
        } else {
            print("✅ KeychainManager: Saved key '\(key)'")
        }
    }

    /// Retrieve a string value from Keychain
    /// - Parameter key: Unique identifier for the value
    /// - Returns: String value if found, nil otherwise
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                print("❌ KeychainManager: Failed to read key '\(key)' - Status: \(status)")
            }
            return nil
        }

        return value
    }

    /// Delete a value from Keychain
    /// - Parameter key: Unique identifier for the value
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("❌ KeychainManager: Failed to delete key '\(key)' - Status: \(status)")
        } else {
            print("✅ KeychainManager: Deleted key '\(key)'")
        }
    }

    /// Check if a key exists in Keychain
    /// - Parameter key: Unique identifier to check
    /// - Returns: true if key exists, false otherwise
    func exists(key: String) -> Bool {
        return get(key: key) != nil
    }

    /// Clear all Keychain items managed by this app
    /// Use with caution - this will delete all stored credentials
    func clearAll() {
        let secClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        for secClass in secClasses {
            let query: [String: Any] = [kSecClass as String: secClass]
            SecItemDelete(query as CFDictionary)
        }

        print("⚠️ KeychainManager: Cleared all Keychain items")
    }
}

// MARK: - Keychain Keys

extension KeychainManager {
    /// Predefined Keychain keys for BuilderOS
    enum Keys {
        static let ratholeAPIToken = "rathole_api_token"
        static let oracleIP = "oracle_vm_ip"
    }
}
