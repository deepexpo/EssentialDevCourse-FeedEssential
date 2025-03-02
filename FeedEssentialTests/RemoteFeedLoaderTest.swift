//
//  RemoteFeedLoaderTest.swift
//  FeedEssentialTests
//
//  Created by Kuldeep Singh on 18/02/25.
//

import Testing
import Foundation
import FeedEssential

import XCTest


class HTTPClient_Test: HTTPClient{
   
    var message = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestedUrls:[URL] {
        return message.map(\.url)
    }
    
    func getUrl(_ url: URL,completion: @escaping (HTTPClientResult) -> Void){
        message.append((url: url, completion: completion))
    }
    
    func completeWith(_ error: Error , at index : Int = 0){
        message[index].completion(.failure(error))
    }
    
    func completeWith(_ code: Int , _ data :Data = Data(), at index : Int = 0){
        let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        message[index].completion(.success(data,response))
    }
}

public class RemoteFeedLoaderTest : XCTestCase{

     func test_init_doesNothingFromURL()  {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let (client,_) = makeSUT()
        XCTAssertEqual(client.requestedUrls.count, 0)
    }
    
    func test_load_requestDataFromUrl()  {
        let url = URL(string: "https://www.google.com")!
        let (client,sut) = makeSUT(url)
        sut.load(completion: {_ in })
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
     func test_load_requestTwiceDataFromUrl()  {
        let url = URL(string: "https://www.google.com")!
        let (client,sut) = makeSUT(url)
         sut.load(completion: {_ in })
         sut.load(completion: {_ in })
        XCTAssertEqual(client.requestedUrls.count, 2)
       
    }
    
    func test_load_deliverErrorOnClientErro()  {
        let url = URL(string: "https://www.google.com")!
        let (client,sut) = makeSUT(url)
        
        expect(sut, toCompelteWith: .failure(RemoteFeedLoader.Error.connectivityError)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.completeWith(clientError)
        }
        
    }
    
     func test_load_deliverErrorOnNonHTTP200()  {
        let url = URL(string: "https://www.google.com")!
        let (client,sut) = makeSUT(url)
        
        let sampleError = [199,201,300,400,500]
        sampleError.enumerated().forEach { index, code in
            
            expect(sut, toCompelteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                client.completeWith(code, at: index)
            }
        }
    }
    
     func test_load_deliverSuccessOn200WithInvalidJson()  {
         let (client,sut) = makeSUT()
         expect(sut, toCompelteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
            let data = Data("invalidJson".utf8)
            client.completeWith(200, data)
        }
    }
    
    func test_load_deliverSuccessOn200WithEmptyJson()  {
         let (client,sut) = makeSUT()
        expect(sut, toCompelteWith: .success([])) {
            let jSONString = "{\"items\":[]}"
            let data = Data(jSONString.utf8)
            client.completeWith(200, data)
        }
    }
    
   func test_load_deliverSuccessOn200WithValidJson()  {
         let (client,sut) = makeSUT()
        
        let feedItem1 = makeFeedItem(id: UUID(),
                                description: "nil",
                                location: "nil",
                                imageURL: URL(string: "https://www.a-url.com")!)

        let feedItem2 = makeFeedItem(id: UUID(),
                               description: "a description",
                               location: "a location",
                                 imageURL: URL(string: "https://www.a-url.com")!)
        

        let itemsJson = [
            "items" : [feedItem1.json,feedItem2.json]
        ]
        
        expect(sut, toCompelteWith: .success([feedItem1.modal,feedItem2.modal])) {
            client.completeWith(200, makeItemJson(itemsJson))
        }
    }
    
    func test_load_doestNotDeliverResultAfterSUTDeinit()  {
        let client = HTTPClient_Test()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: URL(string: "https://www.google.com")!)
        
        var capturedResult = [LoadFeedResult]()
        sut?.load(completion: {capturedResult.append($0)})
        sut = nil
        client.completeWith(200,makeItemJson([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
        //XCTAssertFalse(didComplete)
    }
    
    
    // Mark :- Helpers
  
   private func makeSUT(_ url: URL = URL(string: "https://www.google.com")!,file : StaticString = #filePath, line : UInt = #line) -> (HTTPClient_Test,RemoteFeedLoader) {
        let client = HTTPClient_Test()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackMemoryLeaks(sut,file:file,line:line)
        trackMemoryLeaks(client,file:file,line:line)
        return (client, sut)
    }
    
    private func trackMemoryLeaks(_ instance : AnyObject?, file : StaticString = #filePath, line : UInt = #line) {
        addTeardownBlock {[weak instance] in
            let message = "Memory Leak detected in \(file):\(line)"
            XCTAssertNil(instance,message)
        }
        
    }
    
    private func makeFeedItem(id: UUID = UUID(),description: String?,location: String?,imageURL: URL = URL(string: "https://www.google.com")!) -> (modal:FeedItem,json:[String:Any]) {
        let modal = FeedItem(id: id, description: description, location: location, imageURL:imageURL)
        
        let json = [
            "id": modal.id.uuidString,
                        "image": modal.imageURL.absoluteString,
                        "description": modal.description,
                        "location": modal.location
        ].compactMapValues({$0})
        return (modal,json)
    }
    
    private func expect(_ sut : RemoteFeedLoader, toCompelteWith expectedResult : RemoteFeedLoader.FeedResult, when action : ()->Void,file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load(completion: { result in
            switch(result,expectedResult){
            case let (.success(result),.success(expectedResult)):
                XCTAssertEqual(result , expectedResult,file: file,line: line)
            case let (.failure(resultError as RemoteFeedLoader.Error),.failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(resultError , expectedError)
            default:
                XCTFail("Expected \(expectedResult), got \(result)")
            }
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp],timeout: 0.1)
        
    }
    
    
    private func makeItemJson(_ anyObject:Any) -> Data {
       return try! JSONSerialization.data(withJSONObject: anyObject)
    }
    

}
