//
//  FeedLoader.swift
//  FeedEssential
//
//  Created by Kuldeep Singh on 18/02/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping ([LoadFeedResult]) -> Void)
}
