//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Miquel Bosch on 26/9/25.
//

import XCTest

class RemoteFeedLoader {
    
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
    
//    @Test func <#test function name#>() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }

}
