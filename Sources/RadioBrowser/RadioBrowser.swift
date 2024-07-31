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
    
    /// Список всех тэгов для радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: Результат запроса или ошибка, возникшая в процессе.
    public func getTags(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[StationTag], RadioError> {
        await perform(.get, .tags(offset: offset, limit: limit))
    }
    
    /// Список всех стран радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: Результат запроса или ошибка, возникшая в процессе.
    public func getCountries(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Country], RadioError> {
        await perform(.get, .countries(offset: offset, limit: limit))
    }
    
    public func getAllStations(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .all(offset: offset, limit: limit))
    }
}

//MARK: - Private methods
private extension RadioBrowser {
    typealias Payload = (data: Data, response: URLResponse)
    
    func perform<T: Decodable>(
        _ method: Request.Method,
        _ endpoint: Endpoint
    ) async -> Result<T, RadioError> {
        await endpoint
            .composeUrl()
            .flatMap(Request.init)
            .method(method)
            .reduce(Result<URLRequest, Error>.success)
            .asyncTryMap(session.data)
            .tryMap(unwrap(payload:))
            .decodeJSON(T.self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    func unwrap(payload: Payload) throws -> Data {
        return payload.data
    }
}
