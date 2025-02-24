//  CimmRequest
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public protocol Path {
    var path: String? { get }
}

public protocol PathJSON {
    var pathJSON: String? { get }
}

public enum PathSample: String {
    case sample = "sample"
}

public enum PathJSONSample: String {
    case sample = "sample"
}

public enum HTTPType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum AuthType: String {
    case basic
    case oauth // TODO
}

// MARK: -

public protocol CimmNetRequestable: CustomStringConvertible {
    associatedtype ResponseType
    
    var path: String { get }
    var HTTPType: HTTPType { get }
    var responseType: ResponseType.Type { get }
    var parameter: String? { get }
    var pathJSON: String? { get }
    var queryItems: [String: String]? { get }
    var bodyItems: [String: String]? { get }
    
    var authType: AuthType? { get }
    var username: String? { get }
    var password: String? { get }
    
    var description: String { get }
}

extension CimmNetRequestable {
    public var description: String {
        let parameterDesc = parameter ?? "nil"
        let pathJSONDesc = pathJSON ?? "nil"
        let queryItemsDesc = queryItems?.description ?? "nil"
        let bodyItemsDesc = bodyItems?.description ?? "nil"
        let authTypeDesc = authType?.rawValue ?? "nil"
        let usernameDesc = username ?? "nil"
        let passwordDesc = password ?? "nil"
        
        return """
        Get all posts:
        path: \(path)
        HTTPType: \(HTTPType)
        responseType: \(responseType)
        parameter: \(parameterDesc)
        pathJSON: \(pathJSONDesc)
        queryItems: \(queryItemsDesc)
        bodyItems: \(bodyItemsDesc)
        authType: \(authTypeDesc)
        username: \(usernameDesc)
        password: \(passwordDesc)
        """
    }
}

public protocol CimmNetResponseProtocol {
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
