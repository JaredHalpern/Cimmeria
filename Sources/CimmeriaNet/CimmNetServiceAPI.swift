//
//  CimmNetServiceAPI
//
//  Copyright Jared Halpern 2025.
//

import Foundation

public protocol CimmNetServiceAPI {
    func cancelAllTasks()
    func cancelTask(for url: URL)
}
