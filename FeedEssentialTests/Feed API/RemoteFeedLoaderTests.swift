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
    
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
            
        }
       
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNotItemsOn200HTTPResponseWithEmptyJSONList(){
        let(sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems(){
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!
        )
    
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }

    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
       
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load {
            capturedResults.append($0) // stubbing
        }
        
        sut = nil // means it is deallocated, not in memory anymore
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: -Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return(sut: sut, client: client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
            
        }
    }
    
    // Factory Method
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues {
            $0
        }
        return (item, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return  try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load {
            capturedResults.append($0) // stubbing
        }
       action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(HTTPClientResult.success(data, response))
        }

    }
    
}
