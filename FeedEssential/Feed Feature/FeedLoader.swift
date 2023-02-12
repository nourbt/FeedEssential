//
//  FeedLoader.swift
//  FeedEssential
//
//  Created by Nour on 09/02/2023.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void )
}
