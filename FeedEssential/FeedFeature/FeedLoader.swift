//
//  FeedLoader.swift
//  FeedEssential
//
//  Created by Kuldeep Singh on 18/02/25.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


public protocol FeedLoader {
     func load(completion: @escaping (LoadFeedResult) -> Void)
}
