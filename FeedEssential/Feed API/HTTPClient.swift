//
//  HTTPClient.swift
//  FeedEssential
//
//  Created by Nour on 02/04/2023.
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
