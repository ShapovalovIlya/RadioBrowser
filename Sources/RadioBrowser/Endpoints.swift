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
    static let search = Endpoint.stations.appending(path: "search")
    
    static func countries(offset: Int, limit: Int) -> Self {
        Endpoint
            .countries
            .pagination(offset: offset, limit: limit)
    }
    
    static func topVote(offset: Int, limit: Int) -> Self {
        Endpoint
            .stations
            .appending(path: "topvote")
            .commonItems(offset: offset, limit: limit)
    }
    
    static func all(offset: Int, limit: Int) -> Self {
        Endpoint
            .search
            .commonItems(offset: offset, limit: limit)
    }
}
