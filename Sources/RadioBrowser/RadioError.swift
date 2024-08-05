//
//  RadioError.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 01.08.2024.
//

import Foundation

/// Тип ошибок, возникающих в процессе работы ``RadioBrowser``.
public enum RadioError: Error, Sendable {
    case badRequest
    case forbidden
    case notFound
    case notAllowed
    case internalServerError
    case decodeFail(DecodingError)
    case encodeFail(EncodingError)
    case unknown(Error)
    
    init?(statusCode: Int) {
        switch statusCode {
        case 400: self = .badRequest
        case 403: self = .forbidden
        case 404: self = .notFound
        case 405: self = .notAllowed
        case 500...599: self = .internalServerError
        default: return nil
        }
    }
    
    static func map(_ error: Error) -> RadioError {
        switch error {
        case let radioError as RadioError:
            return radioError
            
        case let reason as DecodingError:
            return .decodeFail(reason)
            
        case let reason as EncodingError:
            return .encodeFail(reason)
            
        default:
            return .unknown(error)
        }
    }
}

extension RadioError: Equatable {
    public static func == (lhs: RadioError, rhs: RadioError) -> Bool {
        String(reflecting: lhs) == String(reflecting: rhs)
    }
}
