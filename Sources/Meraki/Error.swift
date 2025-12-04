//
//  Error.swift
//  MerakiKit
//
//  Created by Sarfraz Basha on 4/12/2025.
//

import Foundation

public enum MerakiError: Error {
    case networkIdNotSet
    case keysFetcherNotImplemented
    case managedAppConfigNotFound
    case noDevicesFound
    case multipleDevicesFound
}

