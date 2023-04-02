//
//  RemoteFeedLoader.swift
//  FeedEssential
//
//  Created by Nour on 12/02/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
// HTTPClient can be public as it could be implemented by external modules
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    // can be created by external modules, so make it public
   public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    // within our method we invoke somthng like HTTPClient..
    // default closure
    public func load(completion: @escaping (Result) -> Void) {
        // mapping between our Error and the domain Error connectivity
        client.get(from: url) { result in
            switch result {
            case let .success(data, response) :
                if response.statusCode == 200, let root = try?
                    JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map{
                        $0.item
                    }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL // name matches API
    
    // a way to map our Item to FeedItem
    var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
