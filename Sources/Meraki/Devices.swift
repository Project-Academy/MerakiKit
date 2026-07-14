//
//  Devices.swift
//  MerakiKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation
import Tapioca

internal enum DevicesAPI: Endpoints {
    public typealias API = Meraki
    public static let base: URL = Meraki.baseURL.appending(path: "networks/\(Meraki.networkId)/sm")
    
    case list
    
    public var path: URL {
        switch self {
        case .list: return Self.base.appending(path: "devices")
        }
    }
    
}

public struct Device: Decodable {
    
    let id: String
    public let uuid: String
    public let serial: String
    public var name: String
    public var tags: [String]
    public var osName: String
    public var model: String
    public var notes: String?
    public var storage: Int?
    
    public var hasLockedUsername: Bool {
        lockedUsername != nil
    }
    public var lockedUsername: String? {
        guard let notes else { return nil }
        guard let uNameRange = notes.range(of: "<username:"),
              let endRange = notes[uNameRange.upperBound...].range(of: ">")
        else { return nil }
        let uNameStart = uNameRange.upperBound
        let uNameEnd = endRange.lowerBound
        // An empty `<username:>` tag IS a lock — to nobody. The device is pinned and
        // no one may log in on it (the login screen says so). Only the ABSENCE of the
        // tag means "not locked"; returning nil here would have made those devices
        // free-text, which is the opposite of what the tag is for.
        return String(notes[uNameStart..<uNameEnd]).trimmingCharacters(in: .whitespaces)
    }
    
    //--------------------------------------
    // MARK: - FUNCTIONS -
    //--------------------------------------
    public static func list() async throws -> [Device] {
        try await DevicesAPI.list.GET
            .params(["fields[]": "tags,notes,deviceCapacity"])
            .response()
            .asType([Device].self)
    }
    public static func get(serials: [String]) async throws -> [Device] {
        try await DevicesAPI.list.GET
            .params(["fields[]": "tags,notes,deviceCapacity",
                     "serials[]": serials.joined(separator: ",")])
            .response()
            .asType([Device].self)
    }
    /// - warning: This requires Managed App Config
    public static func getThisDevice() async throws -> Device {
        guard let serial = await Meraki.deviceSerial
        else { throw MerakiError.managedAppConfigNotFound }
        
        let devices = try await get(serials: [serial])
        guard devices.count > 0
        else { throw MerakiError.noDevicesFound }
        guard devices.count == 1,
              let thisDevice = devices.first
        else { throw MerakiError.multipleDevicesFound }
        return thisDevice
    }
    
    //--------------------------------------
    // MARK: - CODABLE -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case serial = "serialNumber"
        case name
        case tags
        case osName
        case model = "systemModel"
        case notes
        case storage = "deviceCapacity"
    }
    
}
