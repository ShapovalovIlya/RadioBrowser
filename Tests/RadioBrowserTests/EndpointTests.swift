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
        let exp = URL(string: "http://91.132.145.114/json/countries?offset=0&limit=20")
        let sut = makeSut(.countries(offset: 0, limit: 20))
        
        #expect(sut == exp)
    }

    @Test func tags() async throws {
        let exp = URL(string: "http://91.132.145.114/json/tags?offset=0&limit=20")
        let sut = makeSut(.tags(offset: 0, limit: 20))
        
        #expect(sut == exp)
    }
    
    @Test func topVote() async throws {
        let exp = URL(string: "http://91.132.145.114/json/stations/topvote?hidebroken=true&offset=0&limit=20")
        let sut = makeSut(.topVote(offset: 0, limit: 20))
        
        #expect(sut == exp)
    }
    
    @Test func stationClick() async throws {
        let id = UUID()
        let exp = URL(string: "http://91.132.145.114/json/url/".appending(id.uuidString))
        let sut = makeSut(.vote(for: id))
        
        #expect(sut == exp)
    }

    @Test func allStations() async throws {
        let exp = URL(string: "http://91.132.145.114/json/stations/search?hidebroken=true&offset=0&limit=20")
        let sut = makeSut(.all(offset: 0, limit: 20))
                
        #expect(sut == exp)
    }
    
    @Test func searchByName() async throws {
        let exp = URL(string: "http://91.132.145.114/json/stations/search?name=baz&hidebroken=true&offset=0&limit=20")
        let sut = makeSut(.search(byName: "baz", offset: 0, limit: 20))
                
        #expect(sut == exp)
    }
    
    @Test func searchByUUIDs() async throws {
        let id = UUID()
        let exp = URL(string: "http://91.132.145.114/json/stations/byuuid?uuids=".appending(id.uuidString))
        let sut = makeSut(.stations(withIds: [id]))
        
        #expect(sut == exp)
    }
}

private extension EndpointTests {
    func makeSut(_ endpoint: Endpoint) -> URL {
        endpoint.composeUrl().value
    }
    
}
