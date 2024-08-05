// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftFP
import OSLog

public final class RadioBrowser: Sendable {
    
    /// Публичный экземпляр `RadioBrowser` с конфигурацией по умолчанию.
    public static let `default` = RadioBrowser()
    
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
    
    /// Возвращает cписок всех тэгов для радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: Результат запроса или ошибка, возникшая в процессе.
    @Sendable
    public func getTags(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[StationTag], RadioError> {
        await perform(.get, .tags(offset: offset, limit: limit))
            .decodeJSON([StationTag].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает cписок всех стран радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    @Sendable
    public func getCountries(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Country], RadioError> {
        await perform(.get, .countries(offset: offset, limit: limit))
            .decodeJSON([Country].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает cписок всех радио станций
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    @Sendable
    public func getAllStations(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .all(offset: offset, limit: limit))
            .decodeJSON([Station].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает cписок радио-станций с самым высоким рейтингом
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    @Sendable
    public func getPopularStation(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .topVote(offset: offset, limit: limit))
            .decodeJSON([Station].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает cписок радио-станций, чью название совпадает/ содержит передаваемую строку
    /// - Parameters:
    ///   - name: название радио-станции
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    @Sendable
    public func searchStation(
        named name: String,
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(.get, .search(byName: name, offset: offset, limit: limit))
            .decodeJSON([Station].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает cписок радио-станций, ассоциированных с переданными идентификаторами.
    ///
    ///  Ожидаемое поведение:
    ///  - Сервис отдаст станции для указанных `UUID`
    ///  - Сервис отдаст столько станций, сколько передано `UUID` в метод
    ///
    /// - Parameter uuids: массив уникальных идентификаторов радио-станций
    /// - Returns: Массив с радио станциями, согласно переданным `UUID`, либо ошибка, возникшая в процессе запроса
    @Sendable
    public func getStations(withIds uuids: [UUID]) async -> Result<[Station], RadioError> {
        await perform(.get, .stations(withIds: uuids))
            .decodeJSON([Station].self, decoder: decoder)
            .mapError(RadioError.map(_:))
    }
    
    /// Возвращает радио-станцию по переданному `UUID`, если такая есть
    /// - Parameter id: уникальный идентификатор радио-станции
    @Sendable
    public func getStation(withId id: UUID) async -> Result<Station?, RadioError> {
        await perform(.get, .stations(withIds: [id]))
            .decodeJSON([Station].self, decoder: decoder)
            .mapError(RadioError.map(_:))
            .map(\.first)
    }
}

private extension RadioBrowser {
    //MARK: - Payload
    typealias Payload = (data: Data, response: URLResponse)
    
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

//MARK: - Private methods
private extension RadioBrowser {
    
    func perform(
        _ method: RequestType,
        _ endpoint: Endpoint
    ) async -> Result<Data, Error> {
        logger?.trace(
            """
            Performing request... 
            Method: \(String(describing: method))
            
            Endpoint: \(String(describing: endpoint.string))
            """
        )
        return await Result {
            try endpoint
                .composeUrl()
                .flatMap(Request.init)
                .method(method.toMethod)
                .httpBody(method.encodePayload(with: encoder))
                .value
        }
        .asyncTryMap(session.data)
        .tryMap(unwrap(payload:))
    }
    
    func unwrap(payload: Payload) throws -> Data {
        guard let httpResponse = payload.response as? HTTPURLResponse else {
            logger?.error("Invalid response type: \(String(describing: payload.response))")
            throw URLError(.cannotParseResponse)
        }
        return payload.data
    }
}
