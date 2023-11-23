//
//  APIClient.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation
import Combine
import DylKit

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

protocol LocalizedDescriptionError: Error {
    var localizedDescription: String { get }
}

enum APIError: LocalizedDescriptionError {
    case couldntDecode(String, DecodingError)
    case notAuthenticated
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .notAuthenticated: return "Not authenticated"
        case let .couldntDecode(string, error): return """
        \(error.localizedDescription)
        
        \(string)
        """
        case .unknown: return "Unknown error"
        }
    }
}

class APIClient {
    func makeRequest<T: Decodable>(_ request: APIRequest, for type: T.Type) -> AnyPublisher<T, APIError> {
        URLSession.shared.dataTaskPublisher(for: request.request).tryMap { data, response in
            do {
                var data = data
                
                let comps = data.string.components(separatedBy: "for (;;);").compactMap {
                    $0.isEmpty ? nil : $0
                }
                
                if comps.count > 1 {
                    data = ("[" + comps.joined(separator: ",") + "]").data(using: .utf8)!
                }
                
                let value = try JSONDecoder().decode(type, from: data)
                return value
            } catch {
                if data.string.contains("Please try closing and re-opening your browser") {
                    throw APIError.notAuthenticated
                } else if let decodingError = error as? DecodingError {
                    throw APIError.couldntDecode(data.string, decodingError)
                } else {
                    throw error
                }
            }
        }.mapError {
            switch $0 {
            case let apiError as APIError: return apiError
            default: return .unknown
            }
        }
        .eraseToAnyPublisher()
    }
}
