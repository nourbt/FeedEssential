//
//  RemoteFeedLoader.swift
//  FeedEssential
//
//  Created by Nour on 12/02/2023.
//

import Foundation

// HTTPClient can be public as it could be implemented by external modules
public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    // can be created by external modules, so make it public
   public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() { // within our method we invoke somthng like HTTPClient..
        client.get(from: url)
    }
}
