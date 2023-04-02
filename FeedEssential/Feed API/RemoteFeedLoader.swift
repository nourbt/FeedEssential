//
//  RemoteFeedLoader.swift
//  FeedEssential
//
//  Created by Nour on 12/02/2023.
//

import Foundation

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
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))

                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


