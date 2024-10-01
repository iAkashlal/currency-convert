//
//  NetworkRequest.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

enum HTTPMethod: String {
    case post = "PUT"
    case put = "POST"
    case get = "GET"
}

protocol NetworkRequest {
    var scheme: String {get}
    var host: String {get}
    var version: String {get}
    var path: String {get}
    var httpMethod: HTTPMethod {get}
    var headers: [String:String]? {get}
    var body: Data? {get}
    var queryParameters: [String: String] {get}
}

extension NetworkRequest {
    
    private var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = version + path
        urlComponents.queryItems = queryParameters.compactMap({ key, value in
            return URLQueryItem(name: key, value: value)
        })
        return urlComponents.url
    }
    
    var request: URLRequest? {
        guard let url = url else {
            Logger.sharedInstance.log(
                message: "Failed to create URL, check TargetAPI setup \(#file) \(#line)",
                logLevel: .error
            )
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        Logger.sharedInstance.log(
            message: "URL Request created - \(request)",
            logLevel: .info
        )
        return request
    }
}


