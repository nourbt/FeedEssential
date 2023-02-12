//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    func load() { // within our method we invoke somthng like HTTPClient..
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
        
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL){}
    
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL){
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        
        let _ = RemoteFeedLoader()
        
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_request_DataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        
        let sut = RemoteFeedLoader()//Arrange Given a client and sut
        
        
        sut.load() // Act pass as param
        XCTAssertNotNil(client.requestedURL) // Assert
    }
    
}
