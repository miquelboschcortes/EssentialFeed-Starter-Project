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
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() async throws {
        let url = URL(string: "http://a-given-url.com")!
//        let client = HTTPClientSpy()
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
        
    
    // MARK: - Helpers
    
    private class RemoteFeedLoader {
        
        private let client: HTTPClient
        private let url: URL
        
        init(url: URL, client: HTTPClient) {
            self.url = url
            self.client = client
        }
        
        func load() {
            client.get(from: url)
        }
    }

    protocol HTTPClient {
        func get(from url: URL)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
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

// Now we have a class that could be a protocol
// Doing that we can change to inherit and create a subclass to implement it with a protocol
// Our mantra composition over inheritance
// Why? Subclasses creates a tight coupling between the base class and the subclass and violates OPEN/CLOSED principle

final class RemoteFeedLoaderUsingCompositionTests: XCTestCase {
    
    func test_load_requestDataFromURL() async throws {
        let url = URL(string: "http://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoaderCompositionInjection(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private class RemoteFeedLoaderCompositionInjection {
        
        private let client: HTTPClientComposition
        private let url: URL
        
        init(url: URL, client: HTTPClientComposition) {
            self.url = url
            self.client = client
        }
        
        func load() {
            // Now lets resolve the problem about URL
            // URL can be multiple different and it is not the responsability if the RemoteFeedLoader to know which URL have to be used
            // For tha we need to inject the URL
            // We can inject by
            client.get(from: url)
        }
    }

    protocol HTTPClientComposition {
        func get(from url: URL)
    }
    
    private class HTTPClientSpy: HTTPClientComposition {
        
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
    
}

