//
//  DeviceDetails.swift
//  MerakiKit
//
//  Lifted from Library 3/8/2026 — the Meraki SM record is fleet domain,
//  not one app's. Every Device Info panel reads the same holder.
//
//  What the Device settings panel knows about this iPad that isn't
//  available synchronously — the Meraki SM record (lock state, tags,
//  hardware, capacity), which needs a network round-trip and an API key.
//
//  Modelled as an observable holder rather than fetched inline by the
//  panel because `SettingsPanel` is built synchronously: the panel reads
//  whatever this has, and its `observe` hook re-renders the rows when the
//  fetch lands. The rows say what state they're in rather than showing an
//  em-dash that can't be told apart from "the server says empty".
//

import Foundation
import Meraki

@MainActor
@Observable
public final class DeviceDetails {

    public static let shared = DeviceDetails()
    private init() {}

    public enum Status: Equatable, Sendable {
        case idle
        case loading
        /// Meraki answered. The record may still be absent — an unmanaged
        /// device, or a serial the SM network doesn't hold.
        case loaded
        /// Reachability, credentials, or a device with no serial to look up.
        case failed
    }

    public private(set) var status: Status = .idle
    public private(set) var device: Device?

    /// Only one in-flight fetch, so a panel that re-renders on every
    /// observation change doesn't stack requests.
    private var task: Task<Void, Never>?

    /**
     Fetch the SM record, unless one is already in flight.

     Deliberately re-fetches on each panel appearance rather than caching
     for a session: the lock tag is edited in Meraki while someone stands
     at the iPad, and a stale "Locked to —" is worse than a slow one. The
     previous answer stays on screen while the new one loads.
     */
    public func refresh() {
        guard task == nil else { return }
        if status == .idle { status = .loading }
        task = Task { [weak self] in
            let fetched = try? await Device.getThisDevice()
            guard let self else { return }
            self.device = fetched
            self.status = fetched == nil ? .failed : .loaded
            self.task = nil
        }
    }
}

//--------------------------------------
// MARK: - LOCAL HARDWARE -
//--------------------------------------
extension DeviceDetails {

    /**
     The hardware identifier (`iPad13,18`), which is what actually
     distinguishes one iPad from another — `UIDevice.current.model` returns
     the flat string "iPad" on every one of them.
     */
    static var hardwareIdentifier: String {
        var system = utsname()
        uname(&system)
        return withUnsafeBytes(of: &system.machine) { raw in
            raw.prefix { $0 != 0 }
                .withUnsafeBytes { String(decoding: $0, as: UTF8.self) }
        }
    }
}

