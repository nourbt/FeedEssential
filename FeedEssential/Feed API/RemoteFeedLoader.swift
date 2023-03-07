//
//  RemoteFeedLoader.swift
//  FeedEssential
//
//  Created by Nour on 12/02/2023.
//

import Foundation

// HTTPClient can be public as it could be implemented by external modules
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    // can be created by external modules, so make it public
   public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    // within our method we invoke somthng like HTTPClient..
    // default closure
    public func load(completion: @escaping (Error) -> Void = { _ in } ) {
        // mapping between our Error and the domain Error connectivity
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
