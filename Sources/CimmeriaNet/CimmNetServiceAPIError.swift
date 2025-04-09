//
//  CimmNetServiceAPIError
//
//  Copyright Jared Halpern 2025.
//

import Foundation

enum CimmNetServiceAPIError: Error {
    case unknownError(Error)
    case unknown(String)
    case failedToDecode(Error)
    case clientError(String)
    case serverError(String)
    case unableToFormRequest(String?)
    case missingSessionId
    case unableToFormat(String)
    case noContent(String)
    // TODO: Have all of these work with Error associated types, not strings
    var message: String {
        switch self {
        case .unknownError(let error):
            return "Unknown error: \(error)"
        case .unknown(let error):
            return "Unknown error: \(error)"
        case .failedToDecode(let error):
            return "Failed to decode response: \(error)"
        case .clientError(let errorString):
            return "Client Error: \(errorString)"
        case .serverError(let errorString):
            return "Server Error: \(errorString)"
        case .unableToFormRequest(let errorString):
            return "Unable to form request: \(errorString)"
        case .missingSessionId:
            return "Missing Session ID"
        case .unableToFormat(let problematicValue):
            return "Unable to format \(problematicValue)"
        case .noContent(let errorString):
            return "Empty response received unexpectedly"
        }
    }
}
