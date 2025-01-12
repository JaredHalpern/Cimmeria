//
//  KeychainService
//
//  Copyright Jared Halpern 2025.
//

import Foundation
import Security

enum KeychainServiceError: Error, Equatable {
    case noPassword
    case decodingError
    case updateError
    case unhandledError(status: OSStatus)
    case returnValueMissing
    
    var message: String {
        switch self {
        case .noPassword:
            return "Error: no password provided."
        case .decodingError:
            return "Error: unable to decode data"
        case .updateError:
            return "Error: unable to update data"
        case .unhandledError(status: let status):
            return "Error: \(status)."
        case .returnValueMissing:
            return "Error: return value missing."
        }
    }
}

protocol KeychainServiceProtocol {
    func savePassword(_ credentials: Credentials) throws -> KeychainServiceResponse
    func loadPassword(_ credentials: Credentials) throws -> KeychainServiceResponse
    func updatePassword(_ credentials: Credentials) throws -> KeychainServiceResponse
}

public struct KeychainServiceResponse {
    var status: OSStatus?
    var result: String?
}

public final class KeychainService: NSObject, KeychainServiceProtocol {
        
    static let shared = KeychainService()
    
    /// Save a password to the keychain
    /// - Parameter credentials: the `Credentials` object containing the username and password.
    /// - Returns: the `OSStatus` of the Keychain action.
    @discardableResult
    public func savePassword(_ credentials: Credentials) throws -> KeychainServiceResponse {
        
        guard credentials.token.count > 0 else {
            debugPrint("Failed to save password. Blank token provided in credentials.")
            throw KeychainServiceError.noPassword
        }

        SecItemDelete(credentials.saveQuery as CFDictionary)
        let status = SecItemAdd(credentials.saveQuery as CFDictionary, nil)
        
        return KeychainServiceResponse(status: status)
    }
    
    /// Load a password from the keychain
    /// - Parameter credentials: the `Credentials` object containing the username and password.
    /// - Returns: the loaded password
    public func loadPassword(_ credentials: Credentials) throws -> KeychainServiceResponse {
        
        var dataResult: AnyObject?
        let status = SecItemCopyMatching(credentials.loadQuery, &dataResult)
        
        guard status == errSecSuccess, let retrievedData = dataResult as? Data else {
            debugPrint("Failed to retrieve password from keychain. Returning nil.")
            return KeychainServiceResponse(status: status, result: nil)
        }
        
        guard let result = String(data: retrievedData, encoding: .utf8) else {
            throw KeychainServiceError.decodingError
        }
        
        return KeychainServiceResponse(status: status, result: result)
    }
    
    /// Update the password associated with the username
    /// - Parameter credentials: the `Credentials` object containing the username and password.
    /// - Returns: the `OSStatus` of the Keychain action.
    @discardableResult
    public func updatePassword(_ credentials: Credentials) throws -> KeychainServiceResponse {
        
        guard credentials.token.count > 0 else {
            debugPrint("Failed to save password. Blank token provided in credentials.")
            throw KeychainServiceError.noPassword
        }
        
        let status = SecItemUpdate(credentials.updateQuery as CFDictionary, credentials.attributes as CFDictionary)
        
        guard status  == noErr else {
            throw KeychainServiceError.updateError
        }
        
        debugPrint("Password has been updated.")
        
        return KeychainServiceResponse(status: status)
    }
}


