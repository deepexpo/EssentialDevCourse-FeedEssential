//
//  URLSessionHTTPClientTest.swift
//  FeedEssentialTests
//
//  Created by Kuldeep Singh on 27/02/25.
//

import XCTest
import FeedEssential

class URLSessionHTTPClient{
    
    private let session: URLSession

        init(session: URLSession = .shared) {
            self.session = session
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            session.dataTask(with: url) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
}

class URLSessionMock : URLSession,@unchecked Sendable {

    var receivedUrls: [URL] = []
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        self.receivedUrls.append(request.url!)
        return URLSessionDataTaskMock()
    }
    
}

class URLSessionDataTaskMock : URLSessionDataTask ,@unchecked Sendable{
    
    override func resume() {
    }
}

final class URLSessionHTTPClientTest: XCTestCase {
    
    
    func test(){
        let url = URL(string: "https://any-url.com")
        let session = URLSessionMock()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url!){ _ in}
        
        XCTAssertEqual(session.receivedUrls, [url!])
        
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
