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
}
