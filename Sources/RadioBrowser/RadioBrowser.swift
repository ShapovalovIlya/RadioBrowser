// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftFP
import OSLog

public final class RadioBrowser {
    //MARK: - Private properties
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let logger: Logger?
    
    //MARK: - init(_:)
    public init(
        config: URLSessionConfiguration = .default,
        logger: Logger? = nil
    ) {
        self.session = URLSession(configuration: config)
        self.logger = logger
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        logger?.trace(#function)
    }
    
    //MARK: - deinit
    deinit {
        logger?.trace(#function)
    }
    
    //MARK: - Public methods
    func getTags() async -> Result<[String], Error> {
        .success([])
    }
}

//MARK: - Private methods
private extension RadioBrowser {
    
}
