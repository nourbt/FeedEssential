//
//  RemoteFeedLoaderTests.swift
//  FeedEssentialTests
//
//  Created by Nour on 11/02/2023.
//

import XCTest
@testable import FeedEssential

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
       let ( _, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // We're testing that the RemoteFeedLoader will request data from URL using the HTTPClient
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }  // Act pass as param
        XCTAssertEqual(client.requestedURLs, [url]) // Assert
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in } // Act pass as param
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url]) // Assert
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
    
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load(){
            capturedError.append($0) // stubbing
            
        }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load {
                capturedError.append($0) // stubbing
            }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedError, [.invalidData])
            
        }
       
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

            var capturedError = [RemoteFeedLoader.Error]()
            sut.load {
                capturedError.append($0) // stubbing
            }
        let invalidJSON = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
            XCTAssertEqual(capturedError, [.invalidData])
       
    }
    // MARK: -Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return(sut: sut, client: client)
    }
    
    // is capturing the URLs passed to the HTTPClient in requestedURLs property
    class HTTPClientSpy: HTTPClient {
    
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        // computed property
        var requestedURLs: [URL] {
            return messages.map {$0.url}
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            //clients only captures values
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(HTTPClientResult.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(HTTPClientResult.success(data, response))
        }

    }
    
}
