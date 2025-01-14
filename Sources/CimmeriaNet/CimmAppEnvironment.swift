//
//  CimmAppEnvironment
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public protocol CimmAppEnvironment {
    var host: String { get }
    var path: String? { get }
    var token: String? { get }
    var apiBaseURL: URL? { get }
}

extension CimmAppEnvironment {
    public var apiBaseURL: URL? {
        var components = URLComponents(string: host)
        
        if let path = path {
            components?.path = path
        }
        return components?.url
    }
}

// MARK: - Environments

public class FakeEnvironment: CimmAppEnvironment {
    public let host = "FAKEURL/api"
    public let path: String? = "/v1"
    public var token: String? = "Token IAmAFakeToken"
}

// Add additional environments as needed for Staging, QA, Development by conforming to AppEnvironment protocol.
