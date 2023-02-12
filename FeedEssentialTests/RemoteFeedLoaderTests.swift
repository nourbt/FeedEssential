//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    init(client: HTTPClient){
        self.client = client
    }
    func load() { // within our method we invoke somthng like HTTPClient..
       client.get(from: URL(string: "https://a-url.com")!)
        
    }
}

protocol HTTPClient {
    func get(from url: URL)
    
}

class HTTPClientSpy: HTTPClient {
     func get(from url: URL){
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
       
        
        let _ = RemoteFeedLoader(client: client)
        
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_request_DataFromURL() {
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(client: client)//Arrange Given a client and sut
        
        
        sut.load() // Act pass as param
        XCTAssertNotNil(client.requestedURL) // Assert
    }
    
}
