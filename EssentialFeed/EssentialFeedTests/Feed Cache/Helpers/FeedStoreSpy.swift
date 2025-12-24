//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Miquel Bosch on 24/12/25.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    //    var deleteCachedFeedCallCount = 0
    //    var insertions: [(items: [FeedItem], timestamp: Date)] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    private var insertionCompletion = [InsertionCompletion]()
    private var deletionCompletion = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        //        deleteCachedFeedCallCount += 1
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        //        insertions.append((items, timestamp))
        insertionCompletion.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
    
    func retrieve() {
        receivedMessages.append(.retrieve)
    }
}
