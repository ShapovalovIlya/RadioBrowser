//
//  Endpoint.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 28.07.2024.
//

import Foundation
import SwiftFP

typealias Endpoint = Monad<URLComponents>

extension Endpoint {
    //MARK: - Scheme
    enum Scheme: String { case http, https }
    
    //MARK: - Methods
    init() { self.init(URLComponents()) }
    
    func scheme(_ s: Scheme) -> Self { scheme(s.rawValue) }
    
    func appending(path: String) -> Self {
        self.path(self.path.appending("/").appending(path))
    }
    
    func queryItems(@QueryItemBuilder _ builder: () -> [URLQueryItem]) -> Self {
        guard let queryItems else { return self.queryItems(builder()) }
        return self.queryItems(queryItems + builder())
    }
    
    func composeUrl() -> Monad<URL> {
        map { components in
            if let url = components.url { return url }
            preconditionFailure(
                "Unable to create url from: ".appending(components.description)
            )
        }
    }
    
    func pagination(offset: Int, limit: Int) -> Self {
        queryItems {
            URLQueryItem(name: "offset", value: offset.description)
            URLQueryItem(name: "limit", value: limit.description)
        }
    }
    
    func commonItems(
        offset: Int,
        limit: Int,
        hidebroken: Bool = true
    ) -> Self {
        queryItems {
            URLQueryItem(name: "hidebroken", value: hidebroken.description)
        }
        .pagination(offset: offset, limit: limit)
    }
    
    //MARK: - endpoints
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

@resultBuilder
enum QueryItemBuilder {
    
    @inlinable
    static func buildBlock(_ components: URLQueryItem...) -> [URLQueryItem] {
        components
    }
}
