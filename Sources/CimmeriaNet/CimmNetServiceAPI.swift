//
//  CimmNetServiceAPI
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public protocol CimmNetServiceAPI {
    func fetchForRequest<ModelType: Decodable>(_ networkRequest: any CimmNetRequestable, modelType: ModelType.Type) async throws -> ModelType
    func cancelAllTasks()
    func cancelTask(for url: URL)
}
