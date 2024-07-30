import Testing
import Foundation
import SwiftFP
@testable import RadioBrowser

struct RadioBrowser {
    @Test func requestTags() async throws {
        
    }
}

private final class StubProtocol: URLProtocol {
    static var responseHandler: ((URL) -> Result<Data, Error>) = { _ in .failure(URLError(.unknown)) }
    static var didStartLoading = false
    
    override func startLoading() {
        Self.didStartLoading = true
        request.url
            .apply(Self.responseHandler)
            .zip(client)
            .map(redirectResult)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func redirectResult(
        _ result: Result<Data, Error>,
        _ client: any URLProtocolClient
    ) {
        client.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .notAllowed)
        
        switch result {
        case let .success(data):
            client.urlProtocol(self, didLoad: data)
            
        case let .failure(error):
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
}
