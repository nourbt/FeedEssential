//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    init(url: URL, client: HTTPClient) {
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

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
       let ( _, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_request_DataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() // Act pass as param
        XCTAssertEqual(client.requestedURL, url) // Assert
    }
    
    // MARK: -Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return(sut: sut, client: client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }

    }
    
}
