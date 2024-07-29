//
//  Test.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 28.07.2024.
//

import Foundation
import Testing
@testable import RadioBrowser

struct EndpointTests {
    
    @Test func countries() async throws {
        let sut = Endpoint
            .countries(offset: 0, limit: 20)
            .composeUrl()
            .value
        
        let exp = URL(string: "http://91.132.145.114/json/countries?offset=0&limit=20")
        #expect(sut == exp)
    }

    @Test func tags() async throws {
        let sut = Endpoint
            .tags(offset: 0, limit: 20)
            .composeUrl()
            .value
        
        let exp = URL(string: "http://91.132.145.114/json/tags?offset=0&limit=20")
        #expect(sut == exp)
    }
    
    @Test func topVote() async throws {
        let sut = Endpoint
            .topVote(offset: 0, limit: 20)
            .composeUrl()
            .value
        
        let exp = URL(string: "http://91.132.145.114/json/stations/topvote?hidebroken=true&offset=0&limit=20")
        #expect(sut == exp)
    }
    
    @Test func stationClick() async throws {
        let id = UUID()
        let sut = Endpoint
            .vote(for: id)
            .composeUrl()
            .value
        
        let exp = URL(string: "http://91.132.145.114/json/url/".appending(id.uuidString))
        #expect(sut == exp)
    }

    @Test func allStations() async throws {
        let sut = Endpoint
            .all(offset: 0, limit: 20)
            .composeUrl()
            .value
        
        let exp = URL(string: "http://91.132.145.114/json/stations/search?hidebroken=true&offset=0&limit=20")
        #expect(sut == exp)
    }
}
