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
    enum Method: String { case GET, POST, PUT, DELETE }
    
    init(_ url: URL) { self.init(URLRequest(url: url)) }
    
    
}
