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
    enum Scheme: String { case http, https }
    
    init() { self.init(URLComponents()) }
    
    func scheme(_ s: Scheme) -> Self { scheme(s.rawValue) }
    
    func appending(path: String) -> Self {
        self.path(self.path.appending("/").appending(path))
    }
    
    func queryItems(_ builder: () -> [URLQueryItem]) -> Self {
        guard let queryItems else { return self.queryItems(builder()) }
        return self.queryItems(queryItems + builder())
    }
    
    static let server = Endpoint()
        .scheme(.http)
        .host("91.132.145.114")
        .path("/json")
    
    
}
