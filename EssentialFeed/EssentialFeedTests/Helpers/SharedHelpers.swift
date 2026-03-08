//
//  SharedHelpers.swift
//  
//
//  Created by Miquel Bosch on 8/1/26.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
