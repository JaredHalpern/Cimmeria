//
//  CimmNetworkServiceFake.swift
//
//  Copyright Jared Halpern 2025.
//

import Foundation

class CimmNetworkServiceFake: CimmNetServiceAPI {
        
    private var environment: CimmAppEnvironment
    
    init(environment: CimmAppEnvironment) {
        self.environment = environment
    }
    
    static let shared = CimmNetworkServiceFake(environment: FakeEnvironment())
    
    func cancelAllTasks() {
    }
    
    func cancelTask(for url: URL) {
    }
    
    func fetchForRequest<ModelType>(_ networkRequest: any CimmNetRequestable, modelType: ModelType.Type) async throws -> ModelType where ModelType : Decodable {
        return try JSONDecoder().decode(modelType, from: Data())
    }
}

