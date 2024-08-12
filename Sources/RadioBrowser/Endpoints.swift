//
//  Endpoints.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 28.07.2024.
//

import Foundation

extension Endpoint {
    static let server = Endpoint()
        .scheme(.http)
        .host("91.132.145.114")
        .path("/json")
    
    static let stations = Endpoint.server.appending(path: "stations")
    static let countries = Endpoint.server.appending(path: "countries")
    static let tags = Endpoint.server.appending(path: "tags")
    static let search = Endpoint.stations.appending(path: "search")
    
    static func countries(offset: Int, limit: Int) -> Self {
        Endpoint
            .countries
            .pagination(offset: offset, limit: limit)
    }
    
    static func tags(offset: Int, limit: Int) -> Self {
        Endpoint
            .tags
            .pagination(offset: offset, limit: limit)
    }
    
    static func topVote(offset: Int, limit: Int) -> Self {
        Endpoint
            .stations
            .appending(path: "topvote")
            .commonItems(offset: offset, limit: limit)
    }
    
    static func vote(for stationId: UUID) -> Self {
        Endpoint
            .server
            .appending(path: "vote")
            .appending(path: stationId.uuidString)
    }
    
    static func all(offset: Int, limit: Int) -> Self {
        Endpoint
            .stations
            .commonItems(offset: offset, limit: limit)
    }
    
    static func search(byName name: String, offset: Int, limit: Int) -> Self {
        Endpoint
            .search
            .queryItems {
                URLQueryItem(name: "name", value: name)
            }
            .commonItems(offset: offset, limit: limit)
    }
    
    static func stations(withIds ids: [UUID]) -> Self {
        Endpoint
            .stations
            .appending(path: "byuuid")
            .queryItems {
                URLQueryItem(
                    name: "uuids",
                    value: ids.map(\.uuidString).joined(separator: ",")
                )
            }
    }
    
}
