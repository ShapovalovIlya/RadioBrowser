import Testing
import Foundation
import SwiftFP
@testable import RadioBrowser

struct RadioBrowserTests {
    private let sut: RadioBrowser
    
    //MARK: - init(_:)
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubProtocol.self]
        sut = RadioBrowser(config: config)
    }
    
    //MARK: - Test cases
    @Test func decodingError() async throws {
        StubProtocol.responseHandler = makeHandler(with: 1)
        
        await #expect(
            performing: {
                try await sut.getTags().get()
            },
            throws: { error in
                guard
                    let radioError = error as? RadioError,
                    case .decodeFail = radioError
                else {
                    return false
                }
                return true
            }
        )
    }
    
    @Test func tags() async throws {
        StubProtocol.responseHandler = makeHandler(with: stubTags)
        
        let exp = try await sut.getTags().get()
        
        #expect(exp == stubTags)
    }
    
    @Test func countries() async throws {
        StubProtocol.responseHandler = makeHandler(with: stubCountries)
        
        let exp = try await sut.getCountries().get()
        
        #expect(exp == stubCountries)
    }
    
//    @Test func allStations() async throws {
//        let stations = [stubStation]
//        StubProtocol.responseHandler = makeHandler(with: stations)
//        
//        let exp = try await sut.getAllStations().get()
//        
//        #expect(exp == stations)
//    }
}

private extension RadioBrowserTests {
    func makeHandler<T: Encodable>(with model: T) -> (URL) -> Result<Data, Error> {
        { _ in Result { try JSONEncoder().encode(model) } }
    }
}

let stubTags = [
    StationTag(name: "baz", stationcount: 0),
    StationTag(name: "bar", stationcount: 1),
    StationTag(name: "foo", stationcount: 2)
]

let stubCountries = [
    Country(name: "baz", iso31661: "baz", stationcount: 0),
    Country(name: "bar", iso31661: "bar", stationcount: 1),
    Country(name: "foo", iso31661: "foo", stationcount: 2)
]

let stubStation = Station(
    changeUUID: UUID(),
    stationUUID: UUID(),
    serverUUID: UUID(),
    name: "baz",
    url: "baz",
    urlResolved: "baz",
    homepage: "baz",
    favicon: "baz",
    tags: [],
    countryCode: "baz",
    state: "baz",
    language: [],
    languageCodes: [],
    votes: 1,
    codec: "baz",
    bitrate: 1,
    lastCheckOk: true,
    lastCheckTime: .now,
    lastCheckOkTime: .now,
    lastLocalCheckTime: .now
)

