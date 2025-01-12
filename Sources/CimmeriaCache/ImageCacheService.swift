//
//  ImageCacheService.swift
//  RecipeApp
//
//

import Foundation
import SwiftUI
import UIKit

protocol ImageCacheServiceAPI {
    func get(key: URL) -> Data?
    func set(_ value: Data, _ key: URL)
}

/// Cache uses remote-url and local filename.
/// We then retrieve the file data using the local filename.
final class ImageCacheService: CacheService<URL, String> {

    private static var sharedImageCache: ImageCacheService?
        
    private init(capacity: Int) {
        super.init(capacity: capacity)
    }
    
    class func shared(capacity: Int = 500) -> ImageCacheService {
        if let shared = sharedImageCache {
            return shared
        } else {
            let cache = ImageCacheService(capacity: capacity)
            sharedImageCache = cache
            return cache
        }
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("ImageCacheService init(from:) has not been implemented")
    }
    
    /// Gets image from local disk
    /// - Parameter key: The remote url. This is used to obtain the filename from the cache which is how the file is stored locally on disk.
    /// - Returns: The image data from disk, if it exists.
    func getImageDataFromLocalCache(remoteURL: URL) throws -> Data? {
        guard let filename = get(key: remoteURL), let directoryURL = getDocumentsDirectory() else {
            return nil
        }
        
        let fileURL = directoryURL.appending(path: filename)
        let imageData = try loadDataFromDisk(path: fileURL)
        return imageData
    }
    
    func set(imageData: Data, remoteURL: URL, filename: String) {
        do {
            try saveDataToDisk(data: imageData, filename:filename)
            set(filename, remoteURL)
        } catch {
            print("ImageCacheService - error updating cache with remoteURL with key: \(remoteURL) and value: \(filename)")
        }
    }
}
