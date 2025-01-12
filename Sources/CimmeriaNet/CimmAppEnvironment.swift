//
//  CimmAppEnvironment
//
//  Copyright Jared Halpern 2025.
//

import Foundation

protocol CimmAppEnvironment {
    var host: String { get }
    var path: String { get }
    var token: String { get }
    var apiBaseURL: URL { get }
}

extension CimmAppEnvironment {
    var apiBaseURL: URL {
        URL(string: host + path)!
    }
}

// MARK: - Environments

public class FakeEnvironment: CimmAppEnvironment {
    let host = "FAKEURL/api"
    let path = "/v1"
    let token = "Token IAmAFakeToken"
}

// Add additional environments as needed for Staging, QA, Development by conforming to AppEnvironment protocol.
