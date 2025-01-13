//
//  ImageCimmCacheService.swift
//  RecipeApp
//
//

import Foundation
import SwiftUI
import UIKit

public protocol ImageCimmCacheServiceAPI {
    func get(key: URL) -> Data?
    func set(_ value: Data, _ key: URL)
}

/// Cache uses remote-url and local filename.
/// We then retrieve the file data using the local filename.
public final class ImageCimmCacheService: CimmCacheService<URL, String> {

    private static var sharedImageCache: ImageCimmCacheService?
        
    private init(capacity: Int) {
        super.init(capacity: capacity)
    }
    
    public class func shared(capacity: Int = 500) -> ImageCimmCacheService {
        if let shared = sharedImageCache {
            return shared
        } else {
            let cache = ImageCimmCacheService(capacity: capacity)
            sharedImageCache = cache
            return cache
        }
    }
    
    public required init(from decoder: any Decoder) throws {
        fatalError("ImageCacheService init(from:) has not been implemented")
    }
    
    /// Gets image from local disk
    /// - Parameter key: The remote url. This is used to obtain the filename from the cache which is how the file is stored locally on disk.
    /// - Returns: The image data from disk, if it exists.
    public func getImageDataFromLocalCache(remoteURL: URL) throws -> Data? {
        guard let filename = get(key: remoteURL), let directoryURL = getDocumentsDirectory() else {
            return nil
        }
        
        let fileURL = directoryURL.appending(path: filename)
        let imageData = try loadDataFromDisk(path: fileURL)
        return imageData
    }
    
    public func set(imageData: Data, remoteURL: URL, filename: String) {
        do {
            try saveDataToDisk(data: imageData, filename:filename)
            set(filename, remoteURL)
        } catch {
            print("ImageCacheService - error updating cache with remoteURL with key: \(remoteURL) and value: \(filename)")
        }
    }
}
