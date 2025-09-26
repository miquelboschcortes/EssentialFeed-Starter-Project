//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Miquel Bosch on 26/9/25.
//

import XCTest

class RemoteFeedLoader {
    func load() {}
}

class RemoteFeedLoaderConstructorInjection {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {}
}

class HTTPClient {
    var requestedURL: URL?
}

/*
 RemoteFeedLoader is responsible for loading feed data from a remote server.
 Its main responsibilities typically include:
 1. Making HTTP requests to fetch feed data from a given URL or endpoint.
 2. Parsing the received data (often JSON) into model objects.
 3. Handling errors such as connectivity issues, invalid responses, or parsing failures.
 4. Providing a completion handler or async/await interface to deliver the result (success or failure) to the caller.
 In summary, RemoteFeedLoader acts as a service for retrieving feed items from a remote source, abstracting away the networking and parsing logic from the rest of the app.
 */

final class RemoteFeedLoaderTests: XCTestCase {

    // First lets start by the initializer
    func test_doesNotRequesDataFromURL() async throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURLWithConstructorCreation() async throws {
        let client = HTTPClient()
        let sut = RemoteFeedLoaderConstructorInjection(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}

// MARK: - Using Singletons

final class RemoteFeedLoaderUsingSingletonTests: XCTestCase {
    
    func test_load_requestDataFromURL() async throws {
        // This tests is not ideal because it relies on a shared singleton instance.
        // Also, it can lead to issues if tests are run in parallel or if the singleton's state is not properly reset between tests.
        // To use a singleton in the project, we need to consider why we need only onew instance of a class
        let client = HTTPClientSingleton.shared
        let sut = RemoteFeedLoaderSingletonInjection(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private class RemoteFeedLoaderSingletonInjection {
        
        private let client: HTTPClientSingleton
        
        init(client: HTTPClientSingleton) {
            self.client = client
        }
        
        func load() {
            HTTPClientSingleton.shared.requestedURL = URL(string: "http://a-url.com")
        }
    }

    private class HTTPClientSingleton {
        
        static let shared = HTTPClientSingleton()
        
        private init() {}
        
        var requestedURL: URL?
        
    }
    
}

// From this, we can start refactoring and get rid of the singleton.
// To mock a Singleton we have to do the shared variable as a var, to inject the mocked instance.
// This affect on the singleton and change it to Global variable.
// Remember a Global Mutable Variable: every dev can change the instance.

final class RemoteFeedLoaderUsingGlobalStateTests: XCTestCase {
    
    func test_load_requestDataFromURL() async throws {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoaderGlobalStateInjection(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private class RemoteFeedLoaderGlobalStateInjection {
        
        private let client: HTTPClientGlobalState
        
        init(client: HTTPClientGlobalState) {
            self.client = client
        }
        
        func load() {
            client.get(from: URL(string: "http://a-url.com")!)
//            HTTPClientGlobalState.shared.requestedURL = URL(string: "http://a-url.com")
        }
    }

    private class HTTPClientGlobalState {
        
        static var shared = HTTPClientGlobalState() // change to var
        
        init() {}
        
        func get(from url: URL) { }
        
    }
    
    // As we changed as a var and created a Global Mutable Variable, now we can subclass
    
    private class HTTPClientSpy: HTTPClientGlobalState {
        
        var requestedURL: URL?
        
        override func get(from url: URL) {
            requestedURL = url
        }
    }
    
}

