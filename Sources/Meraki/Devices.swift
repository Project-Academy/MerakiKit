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

    // Everything below is only returned when named in `fields[]` — the SM
    // endpoint's default projection is the ten keys above. They decode
    // optionally so a caller that doesn't ask for them still parses.

    /// Free space, in bytes. Pairs with `storage` (total capacity).
    public var availableStorage: Int?
    /// Battery charge as a whole-number percentage — and it arrives as a
    /// STRING ("3"), not a number, so it can't be decoded as `Int`.
    public var batteryPercent: String?
    /// Supervised devices accept the MDM commands unsupervised ones refuse;
    /// on this fleet it should always be true, so a `false` is a finding.
    public var isSupervised: Bool?
    /// Coarse, geo-IP derived ("Kirribilli, Australia") — not a campus, and
    /// not precise enough to locate a device in a building.
    public var location: String?
    /// The device's address on the local network.
    public var localIP: String?
    /// The egress address the campus is seen from — the same signal the
    /// network-presence work keys on.
    public var publicIP: String?
    public var wifiMAC: String?
    /// Unix epoch seconds of the last MDM check-in.
    public var lastConnected: Int?
    /// Deep link to this device in the Meraki dashboard.
    public var dashboardURL: String?

    public var lastConnectedDate: Date? {
        lastConnected.map { Date(timeIntervalSince1970: TimeInterval($0)) }
    }


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
    /**
     The `fields[]` projection every device call asks for. Kept in one
     place so `list` and `get` can't drift into decoding different shapes.

     `color` is deliberately absent because the endpoint REJECTS it —
     `Invalid fields: color`, and likewise `colour` and `deviceColor`
     (verified 2026-07-25 against the live org). The dashboard's device
     list does show a Color column, but it isn't reachable from this API;
     it has to come from the dashboard's CSV export.
     */
    static let requestedFields = [
        "tags", "notes", "deviceCapacity", "availableDeviceCapacity",
        "batteryEstCharge", "isSupervised", "location", "ip", "publicIp",
        "wifiMac", "lastConnected", "url",
    ].joined(separator: ",")

    public static func list() async throws -> [Device] {
        try await DevicesAPI.list.GET
            .params(["fields[]": Device.requestedFields])
            .response()
            .asType([Device].self)
    }
    public static func get(serials: [String]) async throws -> [Device] {
        try await DevicesAPI.list.GET
            .params(["fields[]": Device.requestedFields,
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
        case storage          = "deviceCapacity"
        case availableStorage = "availableDeviceCapacity"
        case batteryPercent   = "batteryEstCharge"
        case isSupervised
        case location
        case localIP          = "ip"
        case publicIP         = "publicIp"
        case wifiMAC          = "wifiMac"
        case lastConnected
        case dashboardURL     = "url"
    }
    
}
