//
//  CimmNetworkServiceFake.swift
//
//  Copyright Jared Halpern 2025.
//

import Foundation

class CimmNetworkServiceFake: CimmNetServiceAPI {
    
    private var environment: AppEnvironment
    
    init(environment: AppEnvironment) {
        self.environment = environment
    }
    
    static let shared = CimmNetworkServiceFake(environment: FakeEnvironment())
    
    func cancelAllTasks() {
    }
    
    func cancelTask(for url: URL) {
    }
}

