//
//  Language.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 31.07.2024.
//

import Foundation

public struct Language: Codable {
    public let name: String
    public let iso_639: String
    public let stationcount: Int
}
