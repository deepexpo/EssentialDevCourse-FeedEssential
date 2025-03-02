//
//  HTTPClient.swift
//  FeedEssential
//
//  Created by Kuldeep Singh on 24/02/25.
//

import Foundation

public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func getUrl(_ url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
