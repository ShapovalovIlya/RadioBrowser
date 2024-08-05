//
//  RadioError.swift
//  RadioBrowser
//
//  Created by Илья Шаповалов on 01.08.2024.
//

import Foundation

public enum RadioError: Error {
    case decodeFail(DecodingError)
    case encodeFail(EncodingError)
    case unknown(Error)
    
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
