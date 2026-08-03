//
//  DeviceLock.swift
//  MerakiKit
//
//  Lifted from Markable's MerakiLockedUsername (P306, 2026-08-03) — the
//  fleet-canonical device-lock reader. Seven apps carried near-copies
//  across THREE parser families, two of them broken (Books/ProjKitx
//  searched `>` from the start of notes; Cortex's MerakiSeam turned
//  locked-to-nobody into unlocked). This is the one copy, on the one
//  correct parser (`Device.lockedUsername`).
//
//  Deliberately NOT conforming to ProjectUI's LockedUsernameProvider:
//  MerakiKit takes no UI-kit dependencies. Each app wraps this in ~3
//  lines — the price of zero kit-to-kit edges.
//

import Foundation
import UIKit

/**
 The MDM device lock: `<username: x>` in the device's Meraki Notes field.

 Fail-to-last-known by design: a failed lookup (offline, Meraki down, no
 Managed App Config) must not read as "unlocked" — the last good device
 keeps serving until a fetch lands. Freshness bounds the API rate: a lock
 is reassigned on the order of days; 30s still catches a reassignment
 while someone stands at the screen.
 */
public struct MerakiDeviceLock: Sendable {

    public static let defaultFreshness: TimeInterval = 30

    private let freshness: TimeInterval
    private let cache = DeviceCache()

    public init(freshness: TimeInterval = MerakiDeviceLock.defaultFreshness) {
        self.freshness = freshness
    }

    /// The current locked username; nil = not pinned (or nothing known yet).
    /// An empty `<username:>` tag (locked to NOBODY) surfaces as the empty
    /// string — callers that must distinguish it already can.
    ///
    /// The app must configure `Meraki.networkId`/`Meraki.keysFetcher` before
    /// the first read — the kit never sources credentials itself. (2.3.0's
    /// `configureFromInfoPlist` never actually configured: its guard tested
    /// `isEmpty` against a default that is never empty, so every request
    /// threw and the lock served last-known = nil. Deleted rather than fixed
    /// — where credentials live is the app's business, not the kit's.)
    public func currentLockedUsername() async -> String? {
        guard await UIDevice.current.userInterfaceIdiom == .pad else { return nil }
        return await cache.lockedUsername(freshFor: freshness)
    }

    public func deviceSerialDisplay() async -> String? {
        await Meraki.deviceSerial
    }

    /// Serialises the fetch and holds the last good device. The non-Sendable
    /// `Device` stays inside; only the username crosses out.
    private actor DeviceCache {
        private var device: Device?
        private var fetchedAt: Date?

        func lockedUsername(freshFor freshness: TimeInterval) async -> String? {
            if let fetchedAt, Date().timeIntervalSince(fetchedAt) < freshness {
                return device?.lockedUsername
            }
            do {
                let fresh = try await Device.getThisDevice()
                device = fresh
                fetchedAt = Date()
                return fresh.lockedUsername
            } catch {
                return device?.lockedUsername
            }
        }
    }
}
