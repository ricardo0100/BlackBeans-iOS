//
//  API.swift
//  Beans
//
//  Created by Ricardo Gehrke on 12/01/21.
//

import Foundation
import Combine

enum APIError: Error {
    case wrongCredentials
    case serverError
    case badURL
}

class API: ObservableObject {
    
    private let baseURLString = "http://127.0.0.1:5000"
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func login(email: String, password: String) -> AnyPublisher<User, APIError> {
        let query = [URLQueryItem(name: "email", value: email),
                     URLQueryItem(name: "password", value: password)]
        guard let request = createURLRequest(path: "/login", queryItems: query, method: "POST") else {
            return Fail(error: APIError.badURL).eraseToAnyPublisher()
        }
        return urlSession
            .dataTaskPublisher(for: request)
            .tryMap() { try self.getData(from: $0) }
            .decode(type: User.self, decoder: JSONDecoder())
            .mapError { $0 as? APIError ?? .serverError }
            .eraseToAnyPublisher()
    }
    
    func signUp(name: String, email: String, password: String) -> AnyPublisher<User, APIError> {
        let query = [URLQueryItem(name: "name", value: name),
                     URLQueryItem(name: "email", value: email),
                     URLQueryItem(name: "password", value: password)]
        guard let request = createURLRequest(path: "/signup", queryItems: query, method: "POST") else {
            return Fail(error: APIError.badURL).eraseToAnyPublisher()
        }
        return urlSession
            .dataTaskPublisher(for: request)
            .tryMap() { try self.getData(from: $0) }
            .decode(type: User.self, decoder: JSONDecoder())
            .mapError { $0 as? APIError ?? .serverError }
            .eraseToAnyPublisher()
    }
    
    func getResources<T: GetResourceResponse>() -> AnyPublisher<[T], APIError> {
        guard
            let path = path(for: T.self),
            let request = createURLRequest(path: path, queryItems: [])
        else {
            return Fail(error: APIError.badURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { try self.getData(from: $0) }
            .decode(type: [T].self, decoder: JSONDecoder())
            .mapError { $0 as? APIError ?? .serverError }
            .eraseToAnyPublisher()
    }
    
    func postAccounts(accounts: [Account]) -> AnyPublisher<[Account], APIError> {
        /// TODO: Implement request
        Fail(error: APIError.badURL).eraseToAnyPublisher()
    }
    // MARK: Private
    
    private func createURLRequest(path: String, queryItems: [URLQueryItem], method: String = "GET") -> URLRequest? {
        guard let url = URL(string: baseURLString + path) else { return nil }
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = urlComponents.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func path(for type: GetResourceResponse.Type) -> String? {
        switch type {
        case is AccountResponse.Type:
            return "/account"
        default:
            return nil
        }
    }
    
    private func getData(from response: URLSession.DataTaskPublisher.Output) throws -> Data {
        let httpResponse = response.response as? HTTPURLResponse
        
        switch httpResponse?.statusCode {
        case 200:
            return response.data
        case 401, 404:
            throw APIError.wrongCredentials
        default:
            throw APIError.serverError
        }
    }
}
