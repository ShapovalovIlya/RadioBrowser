// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftFP
import OSLog

/// Основной класс для работы с `API all.api.radio-browser`
public final class RadioBrowser: Sendable {
    
    /// Публичный экземпляр `RadioBrowser` с конфигурацией по умолчанию.
    public static let `default` = RadioBrowser()
    
    //MARK: - Private properties
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let logger: Logger?
    
    //MARK: - init(_:)
    
    /// Возвращает экземпляр с использованием пользовательских настроек.
    /// - Parameters:
    ///   - config: экземпляр конфигурации сессии
    ///   - logger: экземпляр логгера
    public init(
        config: URLSessionConfiguration = .default,
        logger: Logger? = nil
    ) {
        self.session = URLSession(configuration: config)
        self.logger = logger
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        logger?.trace("RadioBrowser.\(#function)")
    }
    
    //MARK: - deinit
    deinit {
        logger?.trace("RadioBrowser.\(#function)")
    }
    
    //MARK: - Public methods
    
    /// Возвращает cписок всех тэгов для радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: коллекция ``StationTag`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getTags(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[StationTag], RadioError> {
        await perform(
            .get,
            .tags(offset: offset, limit: limit),
            ofType: [StationTag].self
        )
    }
    
    /// Возвращает cписок всех стран радио станций.
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: коллекция ``Country`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getCountries(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Country], RadioError> {
        await perform(
            .get,
            .countries(offset: offset, limit: limit),
            ofType: [Country].self
        )
    }
    
    /// Возвращает cписок всех радио станций
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: коллекция ``Station`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getAllStations(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(
            .get,
            .all(offset: offset, limit: limit),
            ofType: [Station].self
        )
    }
    
    /// Возвращает cписок радио-станций с самым высоким рейтингом
    /// - Parameters:
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: коллекция ``Station`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getPopularStation(
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(
            .get,
            .topVote(offset: offset, limit: limit),
            ofType: [Station].self
        )
    }
    
    /// Возвращает cписок радио-станций, чью название совпадает/ содержит передаваемую строку
    /// - Parameters:
    ///   - name: название радио-станции
    ///   - offset: отступ. Для пагинации.
    ///   - limit: максимальный размер массива элементов в запросе.
    /// - Returns: коллекция ``Station`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func searchStation(
        named name: String,
        offset: Int = 0,
        limit: Int = 20
    ) async -> Result<[Station], RadioError> {
        await perform(
            .get,
            .search(byName: name, offset: offset, limit: limit),
            ofType: [Station].self
        )
    }
    
    /// Возвращает cписок радио-станций, ассоциированных с переданными идентификаторами.
    ///
    ///  Ожидаемое поведение:
    ///  - Сервис отдаст станции для указанных `UUID`
    ///  - Сервис отдаст столько станций, сколько передано `UUID` в метод
    ///
    /// - Parameter uuids: массив уникальных идентификаторов радио-станций
    /// - Returns: коллекция ``Station`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getStations(withIds uuids: [UUID]) async -> Result<[Station], RadioError> {
        await perform(.get, .stations(withIds: uuids), ofType: [Station].self)
    }
    
    /// Возвращает радио-станцию по переданному `UUID`, если такая есть
    /// - Parameter id: уникальный идентификатор радио-станции
    /// - Returns: ``Station`` или ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func getStation(withId id: UUID) async -> Result<Station?, RadioError> {
        await perform(.get, .stations(withIds: [id]), ofType: [Station].self)
            .map(\.first)
    }
    
    /// Увеличеие счетчика голосов на выбранную радио - станцию
    /// - Parameter id: уникальный идентификатор станции
    /// - Returns: результат, засчитался ли голос или  ошибка ``RadioError``, возникшая в процессе.
    @Sendable
    public func voteForStation(withId id: UUID) async -> Result<VoteResult, RadioError> {
        await perform(.get, .vote(for: id), ofType: VoteResult.self)
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
    
    func perform<T: Decodable>(
        _ method: RequestType,
        _ endpoint: Endpoint,
        ofType type: T.Type
    ) async -> Result<T, RadioError> {
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
        .decodeJSON(type.self, decoder: decoder)
        .mapError(RadioError.map(_:))
        .map(log(success:))
        .mapError(log(failure:))
    }
    
    func log<T: Decodable>(success: T) -> T {
        logger?.trace("Request success!")
        return success
    }
    
    func log(failure: RadioError) -> RadioError {
        logger?.error("Request failed: \(String(describing: failure))")
        return failure
    }
    
    func unwrap(payload: Payload) throws -> Data {
        guard let httpResponse = payload.response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse, userInfo: ["Invalid response": payload.response])
        }
        if let error = RadioError(statusCode: httpResponse.statusCode) {
            throw error
        }
        return payload.data
    }
}
