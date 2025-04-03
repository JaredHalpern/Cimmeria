//
//  CimmNetService
//
//  Copyright Jared Halpern 2025.
//

import Foundation

open class CimmNetService: CimmNetServiceAPI {
    
    typealias DataResponse = (data: Data, response: URLResponse)
    
    private static var sharedNetworkService: CimmNetService?
    
    private var dataTasks: [URL: URLSessionTask] = [:]
    private var environment: CimmAppEnvironment
    private let taskQueue = DispatchQueue(label: "com.networkServiceQueue.taskQueue", attributes: .concurrent)
    
    public init(environment: CimmAppEnvironment) {
        self.environment = environment
    }
    
    public class func shared(environment: CimmAppEnvironment) -> CimmNetService {
        if let shared = sharedNetworkService {
            return shared
        } else {
            let service = CimmNetService(environment: environment)
            sharedNetworkService = service
            print("CimmNetService initialized with environment: \(environment.apiBaseURL)")
            return service
        }
    }
}

extension CimmNetService {
    
    @discardableResult
    @available(iOS 16.0.0, *)
    public func fetchForRequest<ModelType: Decodable>(_ networkRequest: any CimmNetRequestable, modelType: ModelType.Type) async throws -> ModelType {
        
        let request = try makeRequest(networkRequest)
        print("--> request: \(request)")
        guard let url = request.url else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing url.")
        }
        
        // Cancel task if already exists
        cancelTask(for: url)
        
        let data = try await initiateRequest(request: request)
        return try decodeJSON(modelType, data: data)
    }
    
    @discardableResult
    @available(iOS 16.0.0, *)
    public func fetchForRequest<ModelType: Decodable>(_ networkRequest: any CimmNetRequestable, modelType: [ModelType].Type) async throws -> [ModelType] {
        
        let request = try makeRequest(networkRequest)
        print("--> request (v2): \(request)")
        guard let url = request.url else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing url.")
        }
        
        // Cancel task if already exists
        cancelTask(for: url)
        
        let data = try await initiateRequest(request: request)
        return try decodeJSON(modelType, data: data)
    }
    
    /// Cancel a specified network task in the queue.
    /// - Parameter url: The URL of the network task to cancel.
    public func cancelTask(for url: URL) {
        self.taskQueue.async (flags: .barrier) {
            self.dataTasks[url]?.cancel()
            self.dataTasks.removeValue(forKey: url)
        }
    }
    
    /// Cancel all outgoing network tasks in the queue.
    public func cancelAllTasks() {
        self.taskQueue.async (flags: .barrier) {
            for task in self.dataTasks.values {
                task.cancel()
            }
            self.dataTasks.removeAll()
        }
    }
}

extension CimmNetService {

    // TODO: - update documentation
    /// Download and return `Data` from a given `URL`
    /// - Parameter url: The `URL` from which to download the `Data`.
    /// - Returns: Downloaded `Data`.
    @available(iOS 13.0.0, *)
    private func initiateRequest(request: URLRequest) async throws -> Data {
        
        guard let url = request.url else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing url.")
        }
        
        var data: Data
        
        let dataResponse: DataResponse = try await URLSession.shared.data(for: request)
        
        if let response = dataResponse.response as? HTTPURLResponse {
            switch response.statusCode {
            case 200..<300:
                return dataResponse.data
            case 400..<500:
                throw CimmNetServiceAPIError.clientError("\(response.statusCode)")
            case 500..<600:
                throw CimmNetServiceAPIError.serverError("\(response.statusCode)")
            default:
                throw CimmNetServiceAPIError.unknown("\(response.statusCode)")
            }
        }
        throw CimmNetServiceAPIError.unknown("Unknown error")
    }
}

// MARK: - Private

extension CimmNetService {

    @available(iOS 16.0, *)
    private func GETRequest(networkRequest: any CimmNetRequestable) throws -> URLRequest {
        
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing api base url.")
        }

        let path = networkRequest.path
        let parameter = networkRequest.parameter // is this being used?
        let queryItems = networkRequest.queryItems
        
        var components = URLComponents(string: apiBaseURL.absoluteString)
        components?.path = path
        
        var queryItemsToAppend = [URLQueryItem]()
        
        queryItems?.forEach({ key, value in
            queryItemsToAppend.append(URLQueryItem(name: key, value: value))
        })
        
        if queryItemsToAppend.count > 0 {
            components?.queryItems = queryItemsToAppend
        }
        
        guard let url = components?.url else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing components url.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPType.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // assemble auth
        // TODO: - Switch on auth type from request
        
        if
            let username = networkRequest.username,
            let password = networkRequest.password
        {
            if let data = "\(username):\(password)".data(using: .utf8) {
                let authorizationHeader = "Basic \(data.base64EncodedString())"
                request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }
    
    @available(iOS 16.0, *)
    private func POSTrequest(networkRequest: any CimmNetRequestable) throws -> URLRequest {
        
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing api base url.")
        }
        
        let path = networkRequest.path
        let bodyItems = networkRequest.bodyItems
        
        var request = URLRequest(url: apiBaseURL.appending(path: path))
        request.httpMethod = HTTPType.POST.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [:]
        
        bodyItems?.forEach({ (key, value) in
            body[key] = value
        })
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // assemble auth
        // TODO: - Switch on auth type from request
        
        if
            let username = networkRequest.username,
            let password = networkRequest.password
        {
            if let data = "\(username):\(password)".data(using: .utf8) {
                let authorizationHeader = "Basic \(data.base64EncodedString())"
                request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    /// UNTESTED
    /// - Parameter path:
    /// - Returns:
    @available(iOS 16.0, *)
    private func DELETErequest(networkRequest: any CimmNetRequestable) throws -> URLRequest {
        
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing api base url.")
        }
        
        let path = networkRequest.path
        let parameter = networkRequest.parameter // is this being used?
        let queryItems = networkRequest.queryItems
        
        var components = URLComponents(string: apiBaseURL.absoluteString)
        components?.path = path

        var queryItemsToAppend = [URLQueryItem]()
        
        queryItems?.forEach({ key, value in
            queryItemsToAppend.append(URLQueryItem(name: key, value: value))
        })
        
        if queryItemsToAppend.count > 0 {
            components?.queryItems = queryItemsToAppend
        }
        
        guard let url = components?.url else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing components url.")
        }
        
//        var request = URLRequest(url: apiBaseURL.appending(path: path))
        var request = URLRequest(url: url)
        request.httpMethod = HTTPType.DELETE.rawValue
//        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if
            let username = networkRequest.username,
            let password = networkRequest.password
        {
            if let data = "\(username):\(password)".data(using: .utf8) {
                let authorizationHeader = "Basic \(data.base64EncodedString())"
                request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }
    
    /// UNTESTED
    /// - Parameter path:
    /// - Returns:
    @available(iOS 16.0, *)
    private func PUTrequest(networkRequest: any CimmNetRequestable) throws -> URLRequest {
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest("Missing api base url.")
        }
        
        let path = networkRequest.path
        
        var request = URLRequest(url: apiBaseURL.appending(path: path))
        request.httpMethod = HTTPType.PUT.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if
            let username = networkRequest.username,
            let password = networkRequest.password
        {
            if let data = "\(username):\(password)".data(using: .utf8) {
                let authorizationHeader = "Basic \(data.base64EncodedString())"
                request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }
    
    /// Assemble the request
    /// - Parameter networkRequest: the network request containing request info
    /// - Returns: A URLRequest which can be executed
    @available(iOS 16.0, *)
    private func makeRequest(_ networkRequest: any CimmNetRequestable) throws -> URLRequest {
        switch networkRequest.HTTPType {
        case .GET:
            return try GETRequest(networkRequest: networkRequest)
        case .POST:
            return try POSTrequest(networkRequest: networkRequest)
        case .PUT:
            return try PUTrequest(networkRequest: networkRequest)
        case .DELETE:
            return try DELETErequest(networkRequest: networkRequest)
        }
    }
}

extension CimmNetService {
  
    /// Exists in a separate function for when we build out the rest of the HTTP methods: POST, etc. Can also add analytics around failed fields here.
    private func decodeJSON<ModelType: Decodable>(_ modelType: ModelType.Type, data: Data) throws -> ModelType {
        do {
            return try JSONDecoder().decode(modelType, from: data)
        } catch {
            throw CimmNetServiceAPIError.failedToDecode(error)
        }
    }
    
    private func decodeJSON<ModelType: Decodable>(_ modelType: [ModelType].Type, data: Data) throws -> [ModelType] {
        do {
            return try JSONDecoder().decode(modelType, from: data)
        } catch {
            throw CimmNetServiceAPIError.failedToDecode(error)
        }
    }
}
