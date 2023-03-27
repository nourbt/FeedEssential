//
//  FeedItem.swift
//  FeedEssential
//
//  Created by Nour on 09/02/2023.
//

import Foundation

public struct FeedItem: Equatable{
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL){
         self.id = id
         self.description = description
         self.location = location
         self.imageURL = imageURL
    }
}

// we need to provide some mapping instructions since FeedItem has imageURL while the json in response has image
extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
