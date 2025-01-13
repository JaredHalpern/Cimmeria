//  CimmRequest
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public enum Path: String {
    case sample = "sample"
}

public enum PathJSON: String {
    case sample = "sample"
}

public enum HTTPType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: -

public protocol CimmNetRequestable: CustomStringConvertible {
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
