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
    case unableToFormRequest
    case missingSessionId
    case unableToFormat(String)
    
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
        case .unableToFormRequest:
            return "Unable to form request"
        case .missingSessionId:
            return "Missing Session ID"
        case .unableToFormat(let problematicValue):
            return "Unable to format \(problematicValue)"
        }
    }
}
