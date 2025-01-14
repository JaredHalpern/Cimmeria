//
//  CimmNetServiceStub.swift
//
//  Copyright Jared Halpern 2025.
//

import Foundation

class CimmNetServiceStub: CimmNetServiceAPI {
    
    static let shared = CimmNetServiceStub()
    
    func cancelAllTasks() {
    }
    
    func cancelTask(for url: URL) {
    }
    
    func fetchForRequest<ModelType>(_ networkRequest: any CimmNetRequestable, modelType: ModelType.Type) async throws -> ModelType where ModelType : Decodable {
        return try JSONDecoder().decode(modelType, from: Data())
    }
}
