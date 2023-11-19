//
//  APIClient.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol APIRequest {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: (any Encodable)? { get }
}

extension Encodable {
    func encode() -> Data {
        try! JSONEncoder().encode(self)
    }
}

extension APIRequest {
    var url: URL { baseURL.appendingPathComponent(path) }
}

extension APIRequest {
    var request: URLRequest {
        var r = URLRequest(url: url)
        r.httpMethod = method.rawValue
        r.allHTTPHeaderFields = headers
        r.httpBody = body?.encode()
        return r
    }
}

enum APIError: Error {
    case internetBroke
    case couldntDecode
    case unknown
    
    init(_ decodingError: DecodingError) {
        switch decodingError {
        default: self = .couldntDecode
        }
    }
}

class APIClient {
    func makeRequest<T: Decodable>(_ request: APIRequest, for type: T.Type) -> AnyPublisher<T, APIError> {
        URLSession.shared.dataTaskPublisher(for: request.request).tryMap { data, response in
            let value = try JSONDecoder().decode(type, from: data)
            return value
        }.mapError {
            switch $0 {
            case let apiError as APIError: return apiError
            case let decodingError as DecodingError: return .init(decodingError)
            default: return .unknown
            }
        }
        .eraseToAnyPublisher()
    }
}
