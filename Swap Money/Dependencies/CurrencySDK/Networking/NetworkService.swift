//
//  NetworkService.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

protocol NetworkServiceable {
    
    associatedtype T
    func fetch(request: URLRequest) async throws -> T
}

class NetworkService<T: Decodable>: NetworkServiceable {
    
    let decoder = JSONDecoder()
    
    func fetch(request: URLRequest) async throws -> (T, URLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        let object = try decoder.decode(T.self, from: data)
        return (object, response)
    }
    
    
}

class OERService: NetworkService<OERResponse> { }
