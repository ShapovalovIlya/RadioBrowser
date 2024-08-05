//
//  Station.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 31.07.2024.
//

import Foundation
import CoreLocation
import SwiftFP

public struct Station: Codable, Equatable {
    /// A globally unique identifier for the change of the station information
    public let changeUUID: UUID
    
    /// A globally unique identifier for the station
    public let stationUUID: UUID
    
    /// ?
    public let serverUUID: UUID?
    
    /// The name of the station
    public let name: String
    
    /// The stream URL provided by the user
    public let url: String
    
    /// An automatically "resolved" stream URL.
    /// Things resolved are playlists (M3U/PLS/ASX...), HTTP redirects (Code 301/302)
    public let urlResolved: String
    
    /// URL to the homepage of the stream, so you can direct the user to a page with more information about the stream.
    public let homepage: String
    
    /// URL to an icon or picture that represents the stream. (PNG, JPG)
    public let favicon: String
    
    /// Tags of the stream with more information about it
    public let tags: [String]
    
    /// Official country codes as in ISO 3166-1 alpha-2
    ///
    /// ``https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2``
    public let countryCode: String

    /// Full name of the entity where the station is located inside the country
    public let state: String
    
    /// Languages that are spoken in this stream
    public let language: [String]
    
    /// Languages that are spoken in this stream by code ISO 639-2/B
    ///
    /// ``https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes``
    public let languageCodes: [String]
    
    /// Number of votes for this station. This number is by server and only ever increases. It will never be reset to 0.
    public let votes: Int
    
    /// The codec of this stream recorded at the last check.
    public let codec: String
    
    /// The bitrate of this stream recorded at the last check.
    public let bitrate: Int
    
    /// The current online/offline state of this stream.
    ///
    /// This is a value calculated from multiple measure points in the internet.
    /// The test servers are located in different countries. It is a majority vote.
    public let lastCheckOk: Bool
    
    /// The last time when any radio-browser server checked the online state of this stream
    public let lastCheckTime: Date
    
    /// The last time when the stream was checked for the online status with a positive result
    public let lastCheckOkTime: Date
    
    /// The last time when this server checked the online state and the metadata of this stream
    public let lastLocalCheckTime: Date
    
    /// Latitude on earth where the stream is located.
    public let geoLat: Double?
    
    /// Longitude on earth where the stream is located.
    public let geoLong: Double?
    
    /// Is true, if the stream owner does provide extended information as HTTP headers which override the information in the database.
    public let hasExtendedInfo: Bool?
    
    //MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case changeUUID = "changeuuid"
        case stationUUID = "stationuuid"
        case serverUUID = "serveruuid"
        case name
        case url
        case urlResolved
        case homepage
        case favicon
        case tags
        case countryCode = "countrycode"
        case state
        case language
        case languageCodes = "languagecodes"
        case votes
        case codec
        case bitrate
        case lastCheckOk = "lastcheckok"
        case lastCheckTime = "lastchecktimeIso8601"
        case lastCheckOkTime = "lastcheckoktimeIso8601"
        case lastLocalCheckTime = "lastlocalchecktimeIso8601"
        case geoLat
        case geoLong
        case hasExtendedInfo
    }
    
    //MARK: - init(from: Decoder)
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.changeUUID = try container.decode(UUID.self, forKey: .changeUUID)
        self.stationUUID = try container.decode(UUID.self, forKey: .stationUUID)
        self.serverUUID = try container.decodeIfPresent(UUID.self, forKey: .serverUUID)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.urlResolved = try container.decode(String.self, forKey: .urlResolved)
        self.homepage = try container.decode(String.self, forKey: .homepage)
        self.favicon = try container.decode(String.self, forKey: .favicon)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.state = try container.decode(String.self, forKey: .state)
        self.votes = try container.decode(Int.self, forKey: .votes)
        self.codec = try container.decode(String.self, forKey: .codec)
        self.bitrate = try container.decode(Int.self, forKey: .bitrate)
        self.lastCheckOk = try container.decode(Int.self, forKey: .lastCheckOk) > .zero
        self.lastCheckTime = try container.decode(Date.self, forKey: .lastCheckTime)
        self.lastCheckOkTime = try container.decode(Date.self, forKey: .lastCheckOkTime)
        self.lastLocalCheckTime = try container.decode(Date.self, forKey: .lastLocalCheckTime)
        
        self.hasExtendedInfo = try container.decodeIfPresent(Bool.self, forKey: .hasExtendedInfo)
        self.geoLat = try container.decodeIfPresent(Double.self, forKey: .geoLat)
        self.geoLong = try container.decodeIfPresent(Double.self, forKey: .geoLong)
        
        let separator = ","
        self.tags = try container.decode(String.self, forKey: .tags).components(separatedBy: separator)
        self.language = try container.decode(String.self, forKey: .language).components(separatedBy: separator)
        self.languageCodes = try container.decode(String.self, forKey: .languageCodes).components(separatedBy: separator)
    }
    
    //MARK: - init(_:)
    init(
        changeUUID: UUID,
        stationUUID: UUID,
        serverUUID: UUID,
        name: String,
        url: String,
        urlResolved: String,
        homepage: String,
        favicon: String,
        tags: [String],
        countryCode: String,
        state: String,
        language: [String],
        languageCodes: [String],
        votes: Int,
        codec: String,
        bitrate: Int,
        lastCheckOk: Bool,
        lastCheckTime: Date,
        lastCheckOkTime: Date,
        lastLocalCheckTime: Date,
        geoLat: Double? = nil,
        geoLong: Double? = nil,
        hasExtendedInfo: Bool? = nil
    ) {
        self.changeUUID = changeUUID
        self.stationUUID = stationUUID
        self.serverUUID = serverUUID
        self.name = name
        self.url = url
        self.urlResolved = urlResolved
        self.homepage = homepage
        self.favicon = favicon
        self.tags = tags
        self.countryCode = countryCode
        self.state = state
        self.language = language
        self.languageCodes = languageCodes
        self.votes = votes
        self.codec = codec
        self.bitrate = bitrate
        self.lastCheckOk = lastCheckOk
        self.lastCheckTime = lastCheckTime
        self.lastCheckOkTime = lastCheckOkTime
        self.lastLocalCheckTime = lastLocalCheckTime
        self.geoLat = geoLat
        self.geoLong = geoLong
        self.hasExtendedInfo = hasExtendedInfo
    }
    
    //MARK: - Public methods
    /// Location  on earth where the stream is located.
    public var location: CLLocation? { zip(geoLat, geoLong).map(CLLocation.init) }
    
}
