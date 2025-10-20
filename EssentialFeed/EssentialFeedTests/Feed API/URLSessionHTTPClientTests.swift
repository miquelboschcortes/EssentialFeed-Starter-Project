//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Miquel Bosch on 13/10/25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    func test_getFromURL_permformsGetRequestsWithURL() {
        let url = URL(string: "https://a-url.com")!
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let requestError = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: requestError)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
                XCTAssertEqual(receivedError.domain, requestError.domain)
                XCTAssertEqual(receivedError.code, requestError.code)
            default:
                XCTFail("Expected to fail with error \(requestError), but got success \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> URLSessionHTTPClient {
        URLSessionHTTPClient()
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        /*
         This is a class method. This means that we dont have an instance yet.
         The urlloading system will instantiate our URLProtocolStub only if we can handle the request
         */
        class override func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        class override func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request // We dont wanna do anything w this request so we just returning
        }
        
        /*
         This method is instance method. The framework has accpoeted and now its time to start loading a request
         */
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
