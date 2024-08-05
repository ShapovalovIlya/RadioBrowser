// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftFP
import OSLog

public final class RadioBrowser {
    //MARK: - Private properties
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
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
    public func getCountries(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Country], RadioError> {
        await perform(.get, .countries(offset: offset, limit: limit))
    }
    
    /// Список всех радио станций
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    public func getAllStations(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .all(offset: offset, limit: limit))
    }
    
    /// Список радио-станций с самым высоким рейтингом
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    public func getPopularStation(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .topVote(offset: offset, limit: limit))
    }
}

//MARK: - Private methods
private extension RadioBrowser {
    typealias Payload = (data: Data, response: URLResponse)
    
    func perform<T: Decodable>(
        _ method: RequestType,
        _ endpoint: Endpoint
    ) async -> Result<T, RadioError> {
        await Result {
            try endpoint
                .composeUrl()
                .flatMap(Request.init)
                .method(method.toMethod)
                .httpBody(method.encodePayload(with: encoder))
                .value
        }
        .asyncTryMap(session.data)
        .tryMap(unwrap(payload:))
        .decodeJSON(T.self, decoder: decoder)
        .mapError(RadioError.map(_:))
    }
    
    func unwrap(payload: Payload) throws -> Data {
        return payload.data
    }
}

private extension RadioBrowser {
    //MARK: - RequestType
    enum RequestType {
        case get
        case post(Encodable)
        case put(Encodable)
        case delete
        
        var toMethod: Request.Method {
            switch self {
            case .get: return .get
            case .post: return .post
            case .put: return .put
            case .delete: return .delete
            }
        }
        
        func encodePayload(with encoder: JSONEncoder) throws -> Data? {
            switch self {
            case .get, .delete: return nil
            case .post(let model), .put(let model):
                return try encoder.encode(model)
            }
        }
    }
}
