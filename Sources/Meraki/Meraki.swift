//
//  Meraki.swift
//  MerakiKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation
@_exported import Tapioca

/**
 MerakiKit consists of two 'features':
 (1) Managed App Config, and
 (2) REST API Methods
 
 The Managed App Config allows the app to access the following information **about the current device**:
 1. the current device's name: ``Meraki.deviceName``,
 2. the current device's serial: ``Meraki.deviceSerial``, and
 3. the current device's UDID: ``Meraki.deviceUDID``
 This is only when the app has been embedded with these properties on the Meraki Dashboard and the profile containing that setting has been pushed to the current device.
 
 The REST API allows you to query the Meraki API (after setting the ``Meraki.networkId`` and adding your ``Meraki.keysFetcher`` implementation).
 */

@MainActor
public struct Meraki: Tapioca {
    public typealias R = Request
    
    public static var baseURL: URL = URL(string: "https://api.meraki.com/api/v1")!
    
    //--------------------------------------
    // MARK: - AUTH -
    //--------------------------------------
    public static var networkId: String = "MY-NETWORK-ID"
    static var apiKey: String?
    public static var keysFetcher: (() async throws -> (Credentials))?
    
    //--------------------------------------
    // MARK: - PRE- & POST-PROCESS -
    //--------------------------------------
    public static func preProcess(request: Request) async throws -> Request {
        
        // MARK: Auth
        guard let apiKey
        else {
            let creds = try await keysFetcher?()
            apiKey = creds?.apiKey
            if let network = creds?.networkId { networkId = network }
            return try await preProcess(request: request)
        }
        
        // MARK: Prep
        let updated = request
            .content(type: request.content)
            .accepts(type: request.accepts)
            .setHeader(key: "X-Cisco-Meraki-API-Key", value: apiKey)
        
        return updated
        
    }
    
    public static func postProcess(response: Presto.Response, from request: Request) async throws -> Presto.Response {
        var response = response
        
        // MARK: Error Handling
        guard let statusCode = response.statusCode
        else { throw PrestoError.noStatusCode }
        
        guard statusCode != 200
        else { return response }
        
        print("Status Code: \(statusCode)")
        
        return response
    }
}

public struct Credentials: Codable, Sendable {
    public let apiKey:     String
    public let networkId:  String?
    
    public init(apiKey: String, network: String? = nil) {
        self.apiKey     = apiKey
        self.networkId  = network
    }
}
