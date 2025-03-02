//
//  RemoteFeedLoader.swift
//  FeedEssential
//
//  Created by Kuldeep Singh on 18/02/25.
//

import Foundation



public final class RemoteFeedLoader : FeedLoader{
    
    let client: HTTPClient
    let url: URL
    
   public init(client: HTTPClient,url: URL) {
        self.client = client
        self.url = url
    }
    
    public typealias FeedResult = LoadFeedResult
    
    public enum Error: Swift.Error{
        case invalidData
        case connectivityError
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.getUrl(url, completion: { [weak self] result in
        guard let _ = self else { return } // used to handle memory leak
           switch result{
            case .success(let data,let response):
                
                completion(FeedItemMapper.map(data,response))
            case .failure:
                completion(.failure(Error.connectivityError))
         
            }
            
        })
    }
    
}





