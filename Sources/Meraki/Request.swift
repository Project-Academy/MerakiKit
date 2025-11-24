//
//  Request.swift
//  MerakiKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation
import Tapioca

public struct Request: APIRequest {
    public typealias API = Meraki
    
    //--------------------------------------
    // MARK: - VARIABLES -
    //--------------------------------------
    public var urlRequest: URLRequest
    public var httpMethod: HTTPMethod
    public let baseURL: URL
    
    //--------------------------------------
    // MARK: - INTERNAL STATE -
    //--------------------------------------
    public var headers: [String: String] = [:]
    public var accepts: ContentType = .JSON
    public var content: ContentType = .JSON
    
    public var params: [String: (any Sendable)] = [:]
    public var paramTransformer: (@Sendable ([String: Any]) throws -> Data) = { params in
        try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    public init(url: URL, _ method: HTTPMethod? = nil) {
        baseURL = url
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = (method ?? .GET).rawValue
        httpMethod = method ?? .GET
    }
    
}
