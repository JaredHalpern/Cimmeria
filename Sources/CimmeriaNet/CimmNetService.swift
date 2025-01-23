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
            print("Network Service with environment: \(environment.apiBaseURL)")
            return shared
        } else {
            let service = CimmNetService(environment: environment)
            sharedNetworkService = service
            print("Network Service with environment: \(environment.apiBaseURL)")
            return service
        }
    }
}

extension CimmNetService {
    
    @available(iOS 16.0.0, *)
    public func fetchForRequest<ModelType: Decodable>(_ networkRequest: any CimmNetRequestable, modelType: ModelType.Type) async throws -> ModelType {
        
        let request = try makeRequest(networkRequest)
        
        guard let url = request.url else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        // Cancel task if already exists
        cancelTask(for: url)
        
        let data = try await initiateRequest(request: request)
        
        let result = try decodeJSON(modelType, data: data)
        return result
    }
    
    @available(iOS 16.0.0, *)
    public func fetchForRequest<ModelType: Decodable>(_ networkRequest: any CimmNetRequestable, modelType: [ModelType].Type) async throws -> [ModelType] {
        
        let request = try makeRequest(networkRequest)
        
        guard let url = request.url else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        // Cancel task if already exists
        cancelTask(for: url)
        
        let data = try await initiateRequest(request: request)
        let result = try decodeJSON(modelType, data: data)
        return result
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
            throw CimmNetServiceAPIError.unableToFormRequest
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
    
    // Factory pattern?
    @available(iOS 16.0, *)
    private func GETrequest(path: String, parameter: String?, json: String?, queryItems: [String: String]?) throws -> URLRequest {
        
        // TODO: - Use URLComponents approach here instead:
        
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        var components = URLComponents(string: apiBaseURL.absoluteString)
        components?.path = path
        
        var queryItemsToAppend = [URLQueryItem]()
        
        queryItems?.forEach({ key, value in
            queryItemsToAppend.append(URLQueryItem(name: key, value: value))
        })
        
        components?.queryItems = queryItemsToAppend
        
        guard let url = components?.url else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPType.GET.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("GETrequest: \(request)")
        return request
    }
    
    @available(iOS 16.0, *)
    private func POSTrequest(_ path: String) throws -> URLRequest {
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        var request = URLRequest(url: apiBaseURL.appending(path: path))
        request.httpMethod = HTTPType.POST.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// UNTESTED
    /// - Parameter path:
    /// - Returns:
    @available(iOS 16.0, *)
    private func PUTrequest(_ path: String) throws -> URLRequest {
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        var request = URLRequest(url: apiBaseURL.appending(path: path))
        request.httpMethod = HTTPType.PUT.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// UNTESTED
    /// - Parameter path:
    /// - Returns:
    @available(iOS 16.0, *)
    private func DELETErequest(_ path: String) throws -> URLRequest {
        guard let apiBaseURL = self.environment.apiBaseURL else {
            throw CimmNetServiceAPIError.unableToFormRequest
        }
        
        var request = URLRequest(url: apiBaseURL.appending(path: path))
        request.httpMethod = HTTPType.DELETE.rawValue
        request.setValue(self.environment.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    @available(iOS 16.0, *)
    private func makeRequest(_ networkRequest: any CimmNetRequestable) throws -> URLRequest {
        switch networkRequest.HTTPType {
        case .GET:
            return try GETrequest(path: networkRequest.path,
                                  parameter: networkRequest.parameter,
                                  json: networkRequest.pathJSON,
                                  queryItems: networkRequest.queryItems)
        case .POST:
            return try POSTrequest(networkRequest.path)
        case .PUT:
            return try PUTrequest(networkRequest.path)
        case .DELETE:
            return try DELETErequest(networkRequest.path)
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
