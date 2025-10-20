//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Miquel Bosch on 20/10/25.
//

import Foundation

extension URLSession: HTTPClient {
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        self.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
            
        }.resume()
    }
}
