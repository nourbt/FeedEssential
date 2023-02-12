//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    func load() { // within our method we invoke somthng like HTTPClient..
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
        
    }
}

class HTTPClient {
    static let shared = HTTPClient() // single point of access //Singelton
    private init() {}// private initialzer so no one can create this type
    
    var requestedURL: URL?
    
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClient.shared // communcate with network
        
       // sut.load() // invoke command load feed items
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_request_DataFromURL() {
        let client = HTTPClient.shared// Arrange
        let sut = RemoteFeedLoader()//Arrange Given a client and sut
        
        
        sut.load() // Act pass as param
        XCTAssertNotNil(client.requestedURL) // Assert
    }
    
}
