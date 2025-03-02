//
//  FeedItemMapper.swift
//  FeedEssential
//
//  Created by Kuldeep Singh on 24/02/25.
//

import Foundation

final class FeedItemMapper{
    private class RootNode: Decodable {
        let items: [Item]
    }
    
    private struct Item: Decodable {
        public let id:UUID
        public let description:String?
        public let location:String?
        public let image:URL
        
        var item:FeedItem{
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
        
    }
    
    static func map(_ data:Data,_ response : HTTPURLResponse)  -> RemoteFeedLoader.FeedResult{
        guard response.statusCode == 200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        do{
            let root = try JSONDecoder().decode(RootNode.self, from: data)
            let items = root.items.map({$0.item})
            return .success(items)
        }catch{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
}
