//  CimmCacheService.swift
//
//  Copyright Jared Halpern 2025.

/**
 A basic LRU Cache, key-value store.
 */

import Foundation

public protocol CimmCacheServiceAPI {
    associatedtype Key: Hashable & Codable
    associatedtype Value: Codable
    
    func get(key: Key) -> Value?
    func set(_ value: Value, _ key: Key)
    func saveDataToDisk(data: Data, filename: String) throws
    func loadDataFromDisk(path: URL) throws -> Data?
    func getDocumentsDirectory() -> URL?
}

/// A basic key-value LRU cache.
public class CimmCacheService<Key: Hashable & Codable, Value: Codable>: Codable, CimmCacheServiceAPI {

    private var capacity: Int
    private var cache: [Key: Node<Key, Value>] = [:]
    private var head: Node<Key, Value>?
    private var tail: Node<Key, Value>?
    private var customDocumentsDirectory: URL?
    private let cacheQueue = DispatchQueue(label: "com.recipeApp.cacheServiceQueue.taskQueue", attributes: .concurrent)
    
    enum CodingKeys: CodingKey {
        // Deliberately omit cacheQueue as the DispatchQueue cannot conform to Codable.
        case cache, capacity, head, tail
    }
    
    public required init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CimmCacheService<Key, Value>.CodingKeys> = try decoder.container(keyedBy: CimmCacheService<Key, Value>.CodingKeys.self)
        self.cache = try container.decode([Key : Node<Key, Value>].self, forKey: CimmCacheService<Key, Value>.CodingKeys.cache)
        self.capacity = try container.decode(Int.self, forKey: CimmCacheService<Key, Value>.CodingKeys.capacity)
        self.head = try container.decodeIfPresent(Node<Key, Value>.self, forKey: CimmCacheService<Key, Value>.CodingKeys.head)
        self.tail = try container.decodeIfPresent(Node<Key, Value>.self, forKey: CimmCacheService<Key, Value>.CodingKeys.tail)
    }
    
    public init(capacity: Int = 500, documentsDirectory: URL? = nil) {
        self.capacity = capacity
        self.customDocumentsDirectory = documentsDirectory
    }
    
    public func get(key: Key) -> Value? {
        guard let node = cache[key] else {
            return nil
        }
        moveToHead(node)
        return node.value
    }
    
    public func set(_ value: Value, _ key: Key) {
        cacheQueue.async(flags: .barrier) {
            if let node = self.cache[key] {
                node.value = value
                self.moveToHead(node)
            } else {
                let newNode = Node(key: key, value: value)
                if self.cache.count >= self.capacity {
                    self.removeTail()
                }
                
                self.addToHead(newNode)
                self.cache[key] = newNode
            }
        }
    }
}

extension CimmCacheService {
    private func addToHead(_ node: Node<Key, Value>) {
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
        if tail == nil {
            tail = head
        }
    }
    
    private func moveToHead(_ node: Node<Key, Value>) {
        removeNode(node)
        addToHead(node)
    }
    
    private func removeNode(_ node: Node<Key, Value>) {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }
        
        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }
    }
    
    private func removeTail() {
        guard let tail = tail else { return }
        removeNode(tail)
        cache[tail.key] = nil
    }
}

extension CimmCacheService {
    
    // MARK: - Data Persistence
    
    // TODO: Move this into a separate persistance service
    /// Load data from the disk
    /// - Parameter path: The path, a `URL` from which to load the `Data`.
    /// - Returns: the `Data` if it exists at the given path.
    public func loadDataFromDisk(path: URL) throws -> Data? {
        return try Data(contentsOf: path)
    }
    
    // TODO: Move this into a separate persistance service
    /// Save `Data` to disk
    /// - Parameters:
    ///   - data: The `Data` to save to disk.
    ///   - filename: A filename to use when saving the data.
    public func saveDataToDisk(data: Data, filename: String) throws {
        
        let directory: URL? = getDocumentsDirectory()
        
        if let fileURL = directory?.appendingPathComponent(filename) {
            try data.write(to: fileURL)
        } else {
            print("Unable to retrieve directory so we can save data to disk.")
        }
    }
    
    // TODO: Move this into a separate persistance service
    /// Retrieve the documents directory or use a user-provided custom documents directory if one is provided.
    /// - Returns: The Documents directory to use when persisting and retrieving data.
    public func getDocumentsDirectory() -> URL? {
        if let directory = self.customDocumentsDirectory {
            return directory
        }
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

class Node<Key: Codable, Value: Codable>: Codable {
    var key: Key
    var value: Value
    var prev: Node?
    var next: Node?
    
    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}
