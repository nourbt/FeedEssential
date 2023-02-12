//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
    
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClient() // communcate with network
        
       // sut.load() // invoke command load feed items
        
        XCTAssertNil(client.requestedURL)
        
    }
    
}
