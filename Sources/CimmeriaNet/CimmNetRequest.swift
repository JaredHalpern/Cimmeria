//  CimmRequest
//
//  Copyright Jared Halpern 2025.
//

import Foundation

enum Path: String {
    case device = "device"
    case devices = "devices"
    case sessions = "sessions"
    case none = ""
}

enum PathJSON: String {
    case sessions = "sessions"
    case devices = "devices"
    case chart = "chart"
}

enum HTTPType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: -

protocol CimmNetRequestable: CustomStringConvertible {
    associatedtype ResponseType
    
    var path: Path { get }
    var HTTPType: HTTPType { get }
    var responseType: ResponseType.Type { get }
    var parameter: String? { get }
    var pathJSON: PathJSON? { get }
}

extension CimmNetRequestable {
    var description: String {
        return "CimmNetRequestable: \(self.HTTPType.rawValue) \(self.path)"
    }
}

protocol CimmNetResponseProtocol {
    associatedtype ModelType
    
    var modelType: ModelType.Type {get}
}

// MARK: - Sample Requests

/*
struct ChartDataNetworkRequest: CimmNetRequestable {
    var path: Path {
        return .sessions // path is sessions/<session_id>/chart.json
    }
    
    var HTTPType: HTTPType {
        return .GET
    }
    
    var responseType = ChartDataNetworkResponse.Type.self
    var parameter: String?
    var pathJSON: PathJSON? {
        return .chart
    }
}
 
 
 
 struct ChartDataNetworkResponse: CimmNetResponseProtocol {
     var modelType = ChartModel.self
     var model: ChartModel
 }
 */
