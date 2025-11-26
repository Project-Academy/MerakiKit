//
//  ManagedAppConfig.swift
//  MerakiKit
//
//  Created by Sarfraz Basha on 26/11/2025.
//

import Foundation

extension Meraki {
    
    //--------------------------------------
    // MARK: - DEVICE INFO -
    //--------------------------------------
    public static var deviceName:    String? { Meraki[.deviceName] }
    public static var deviceUDID:    String? { Meraki[.deviceUdid] }
    public static var deviceSerial:  String? { Meraki[.serial] }
    
    public static var hasManagedConfig: Bool { config != nil }
    public static subscript(_ key: ConfigKey) -> String? {
        config?[key.rawValue] as? String
    }
    
    internal static var config: [String: Any]? {
        UserDefaults.standard.dictionary(forKey: MACKey)
    }
    internal static let MACKey = "com.apple.configuration.managed"
    
    
    public enum ConfigKey: String {
        case deviceName = "device_name"
        case serial = "device_serial"
        case deviceUdid = "device_udid"
    }
    
    
}
