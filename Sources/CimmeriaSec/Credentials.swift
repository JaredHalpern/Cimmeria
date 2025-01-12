//  Credentials
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public protocol Queryable {
    var saveQuery: NSMutableDictionary { get }
    var loadQuery: NSMutableDictionary { get }
    var updateQuery: NSMutableDictionary { get }
    var attributes: NSMutableDictionary { get }
}

/// The purpose of this struct is to separate the Credentials
/// data from the logic handling it.
public struct Credentials {
    
    /// The username associated with the password.
    var username: String
    
    /// The token associated with the username.
    var token: String = ""
    
    /// The data representation of the token associated with the username.
    var dataFromTokenString: Data? {
        return token.data(using: .utf8)
    }
    
    /// The service associated with the data to be stored in the keychain.
    let service = Bundle.main.bundleIdentifier ?? "BlackbirdTakehome"
}

extension Credentials: Queryable {
    
    public var saveQuery: NSMutableDictionary {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: username,
            kSecValueData: dataFromTokenString ?? Data()
        ]
    }
    
    public var loadQuery: NSMutableDictionary {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: username,
            kSecReturnData: true
        ]
    }
    
    public var updateQuery: NSMutableDictionary {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username
        ]
    }
    
    public var attributes: NSMutableDictionary {
        return [
            kSecValueData as String: dataFromTokenString ?? Data()
        ]
    }
}
