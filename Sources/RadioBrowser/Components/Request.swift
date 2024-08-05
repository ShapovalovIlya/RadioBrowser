//
//  Request.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 28.07.2024.
//

import Foundation
import SwiftFP

typealias Request = Monad<URLRequest>

extension Request {
    enum Method: String { case get, post, put, delete, head }
    
    init(_ url: URL) { self.init(URLRequest(url: url)) }
    
    @Sendable
    func method(_ m: Method) -> Self { self.httpMethod(m.rawValue.uppercased()) }
}
