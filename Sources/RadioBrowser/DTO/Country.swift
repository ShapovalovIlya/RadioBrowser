//
//  File.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 31.07.2024.
//

import Foundation

public struct Country: Codable, Equatable, Sendable {
    public let name: String
    
    /// iso 3166
    public let iso31661: String
    public let stationcount: Int
}


