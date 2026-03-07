//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Miquel Bosch on 7/3/26.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
        completion(.empty)
    }
}
