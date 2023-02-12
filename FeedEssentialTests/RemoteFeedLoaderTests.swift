//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url : URL
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    func load() { // within our method we invoke somthng like HTTPClient..
        client.get(from: url)
        
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
        let url = URL(string:  "https://a-url.com")!
        let client = HTTPClientSpy()
       
        
        let _ = RemoteFeedLoader(url: url, client: client)
        
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_request_DataFromURL() {
        let url = URL(string:  "https://a-url.com")!
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)//Arrange Given a client and sut
        
        
        sut.load() // Act pass as param
        XCTAssertEqual(client.requestedURL, url) // Assert
    }
    
}
